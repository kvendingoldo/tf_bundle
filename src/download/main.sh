#!/bin/bash

BUILD_DIR="./build"
PROVIDERS_FILE=""
SCRIPT_PATH="$(dirname $(realpath $0))"

function get_latest_release_version() {
    local repo=${1}
    curl -s "https://api.github.com/repos/${repo}/releases/latest" | jq -r .tag_name
}

function main() {

    # Determine OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Normalize architecture names
    case "${ARCH}" in
        amd64|arm64|386|arm)
            ARCH="${ARCH}"
            ;;
        x86_64)
            ARCH="amd64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            echo "[ERROR] Unsupported architecture: ${ARCH}"
            exit 1
            ;;
    esac

    [[ -z "${PROVIDERS_FILE}" ]] && PROVIDERS_FILE="${SCRIPT_PATH}/providers.txt"

    mkdir -p "${BUILD_DIR}" || echo
    mkdir -p ~/.terraform.d/plugins/${OS}_${ARCH}
    cd ${BUILD_DIR}

    while IFS= read -r line; do
        # Skip empty lines and comment lines starting with #
        [[ -z "${line}" || "${line}" =~ ^# ]] && continue

        # Split the line into provider and version
        IFS='=' read -r -a provider_coordinates <<< "${line}"
        provider="${provider_coordinates[0]}"
        version="${provider_coordinates[1]}"

        echo "[INFO] Build ${provider} provider"

        # Determine the GitHub coordinates for the provider
        repo_group=$(echo ${provider} | cut -d'/' -f1)
        repo_name=$(echo ${provider} | cut -d'/' -f2)

        # If no version is specified, get the latest version
        if [ -z "${version}" ]; then
            echo "[WARNING] No version specified for provider ${provider}, fetching latest version..."
            version=$(get_latest_release_version "${repo_group}/${repo_name}")
            if [ -z "${version}" ]; then
                echo "[ERROR] Failed to get the latest version for ${provider}."
                continue
            fi
            echo "[INFO] Latest version for ${provider} is ${version}"
        fi

        # Remove the "v" prefix from the version if it exists
        version=${version#v}

        # Form the URL for downloading the provider from GitHub
        url="https://github.com/${repo_group}/${repo_name}/releases/download/v${version}/${repo_name}_${version}_${OS}_${ARCH}.zip"

        # Download and install the provider
        echo "[INFO] Downloading provider ${provider} version ${version} for ${OS}/${ARCH}..."
        curl -L -O "${url}"

        if [ ${?} -eq 0 ]; then
            echo "[INFO] Provider ${provider} version ${version} successfully downloaded."
        else
            echo "[INFO] Failed to download provider ${provider} version ${version}."
            continue
        fi

        echo $(pwd)
        unzip $(pwd)/${repo_name}_${version}_${OS}_${ARCH}.zip
        chmod +x $(pwd)/${repo_name}

        mv $(pwd)/${repo_name} ~/.terraform.d/plugins/${OS}_${ARCH}/${repo_name}_${version}_${OS}_${ARCH}

    done < "${PROVIDERS_FILE}"

    echo "[INFO] All providers installed."
}

main "${@}"
