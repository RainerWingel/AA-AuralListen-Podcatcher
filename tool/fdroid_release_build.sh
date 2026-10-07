#!/usr/bin/env bash
# Builds release APKs exactly like F-Droid does (reproducible builds,
# docs/f-droid.md): F-Droid's own buildserver image, its fdroidserver,
# the same paths (/home/vagrant/build/...) and the recipe from fdroid/.
# The unsigned APKs land in <out>/unsigned; with --sign they are signed with
# the release key from android/key.properties into <out>/signed.
#
# Needs Docker (on Apple Silicon e.g. OrbStack; runs as linux/amd64).
#
#   tool/fdroid_release_build.sh <out-dir> [--sign] [versionCode ...]
#
# Without version codes all builds of the recipe are made.
set -euo pipefail

APP_ID=io.github.rainerwingel.aurallisten
IMAGE=registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie
REPO="$(cd "$(dirname "$0")/.." && pwd)"
RECIPE="$REPO/fdroid/$APP_ID.yml"

OUT="${1:?usage: $0 <out-dir> [--sign] [versionCode ...]}"
shift
SIGN=false
if [[ "${1:-}" == "--sign" ]]; then
  SIGN=true
  shift
fi
CODES=("$@")
if [[ ${#CODES[@]} -eq 0 ]]; then
  while IFS= read -r code; do CODES+=("$code"); done < <(
    sed -n -E 's/^    versionCode: ([0-9]+)$/\1/p' "$RECIPE")
fi

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
WORK="$OUT/work"
rm -rf "$WORK" "$OUT/unsigned"
mkdir -p "$WORK/metadata" "$WORK/srclibs" "$WORK/tmp" "$OUT/unsigned"
cp "$RECIPE" "$WORK/metadata/"
curl -fsSL -o "$WORK/srclibs/flutter.yml" \
  https://gitlab.com/fdroid/fdroiddata/-/raw/master/srclibs/flutter.yml

TARGETS=()
for code in "${CODES[@]}"; do TARGETS+=("$APP_ID:$code"); done
echo "Building ${TARGETS[*]} in $IMAGE …"

# Same steps as the "fdroid build" job of fdroiddata's CI.
docker run --rm --platform linux/amd64 -v "$WORK:/work" \
  -e TARGETS="${TARGETS[*]}" --entrypoint /bin/bash "$IMAGE" -c '
set -euo pipefail
source /etc/profile.d/bsenv.sh
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
sdkmanager "platform-tools" "build-tools;31.0.0" > /dev/null
git clone --quiet --depth 1 https://gitlab.com/fdroid/fdroidserver.git "$fdroidserver"
export PATH="$fdroidserver:$PATH" PYTHONPATH="$fdroidserver:$fdroidserver/examples"
git -C "$home_vagrant/gradlew-fdroid" pull --quiet || true
for d in .android .gradle metadata; do mkdir -p "$home_vagrant/$d"; done
cp /work/metadata/*.yml "$home_vagrant/metadata/"
ln -s /work/srclibs "$home_vagrant/srclibs"
ln -s /work/tmp "$home_vagrant/tmp"
chown -R vagrant "$home_vagrant" /work
cd "$home_vagrant"
as_vagrant() {
  sudo --preserve-env --user vagrant env PATH="$PATH" PYTHONPATH="$PYTHONPATH" \
    PYTHONUNBUFFERED=true HOME="$home_vagrant" "$@"
}
for target in $TARGETS; do
  # Clone the app and Flutter first, then build – like the CI job.
  as_vagrant fdroid fetchsrclibs "$target" --verbose
  as_vagrant fdroid build --verbose --test --refresh-scanner --on-server \
    --no-tarball "$target"
done
'

cp "$WORK"/tmp/"$APP_ID"_*.apk "$OUT/unsigned/"
echo "Unsigned APKs: $OUT/unsigned"

if $SIGN; then
  # Release key from android/key.properties (never in git).
  props="$REPO/android/key.properties"
  prop() { sed -n -E "s/^$1=(.*)$/\1/p" "$props"; }
  store="$(prop storeFile)"
  [[ "$store" = /* ]] || store="$REPO/android/app/$store"
  build_tools="$(ls -d "${ANDROID_HOME:-$HOME/Library/Android/sdk}"/build-tools/*/ | tail -1)"
  mkdir -p "$OUT/signed"
  for apk in "$OUT"/unsigned/*.apk; do
    signed="$OUT/signed/$(basename "$apk")"
    # --alignment-preserved: only add the signature, change nothing else –
    # F-Droid copies it onto its own build (apksigcopier) to verify.
    KS_PASS="$(prop storePassword)" KEY_PASS="$(prop keyPassword)" \
      "$build_tools/apksigner" sign --alignment-preserved --ks "$store" \
      --ks-key-alias "$(prop keyAlias)" \
      --ks-pass env:KS_PASS --key-pass env:KEY_PASS \
      --out "$signed" "$apk"
    rm -f "$signed.idsig"
  done
  # Same check as F-Droid: the signature must fit the unsigned build.
  docker run --rm --platform linux/amd64 -v "$OUT:/out" --entrypoint /bin/bash \
    "$IMAGE" -c '
set -e
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq apksigcopier > /dev/null 2>&1
for apk in /out/signed/*.apk; do
  apksigcopier compare "$apk" --unsigned "/out/unsigned/$(basename "$apk")"
  echo "verified: $(basename "$apk")"
done
'
  echo "Signed APKs: $OUT/signed"
fi
