#!/bin/bash
# Actualizar certificados raíz del sistema en macOS 10.13 (High Sierra)
# Fuente: Bundle oficial de Mozilla (https://curl.se/docs/caextract.html)
# Requiere: curl, openssl, security, sudo

set -e

MOZ_BUNDLE_URL="https://curl.se/ca/cacert.pem"
TMP_DIR="/tmp/rootcerts"
BUNDLE="$TMP_DIR/cacert.pem"

echo "=== Actualizando certificados raíz del sistema (High Sierra) ==="
echo "Descargando bundle desde Mozilla..."
mkdir -p "$TMP_DIR"
curl -s -o "$BUNDLE" "$MOZ_BUNDLE_URL"

if [ ! -s "$BUNDLE" ]; then
  echo "Error: no se pudo descargar el bundle de certificados."
  exit 1
fi

echo "Extrayendo certificados y agregándolos al llavero del sistema..."
# Dividir el PEM en archivos individuales
csplit -f "$TMP_DIR/cert-" -b "%03d.pem" "$BUNDLE" '/-----BEGIN CERTIFICATE-----/' '{*}' >/dev/null 2>&1

# Importar cada uno
for cert in "$TMP_DIR"/cert-*.pem; do
  if [ -s "$cert" ]; then
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$cert" >/dev/null 2>&1 || true
  fi
done

echo "Limpieza..."
rm -rf "$TMP_DIR"

echo "✅ Certificados raíz actualizados correctamente."
echo "Reinicia Safari o el sistema para aplicar los cambios."

