#!/usr/bin/env bash

#######################################################
# This script downloads the requested WordPress version
# and stores it in the `./wordpress` folder.
#######################################################

WP_DIR="./wordpress";
WP_INC="$WP_DIR/wp-includes";
WP_DL_BASE="https://wordpress.org/";
BACKUP_FILE="$WP_DIR.`date +%s`.tar.gz";

# Reverts changes made by the script
revert() {
    echo "Reverting any changes...";

    if [ -f $BACKUP_FILE ]; then
        tar -xzf $BACKUP_FILE && rm -rf $BACKUP_FILE;
    fi
}

# Checks if the ./wordpress folder contains files
check_existing_wp_install() {
    FILES_PRESENT=$(ls -a $WP_DIR | wc -l);

    if [ "$FILES_PRESENT" -gt 3 ]; then
        echo "Files already exist inside '$WP_DIR'";
        check_wordpress_version;
    fi
}

# Looks for the version of the install in ./wordpress
check_wordpress_version() {
    if [ -f "$WP_INC/version.php" ]; then
        WP_VERS=$(sed -rn "s/^.wp_version\s?=\s?.(.*).;/\1/p" $WP_INC/version.php);

        if [ "$WP_VERS" ]; then
            maybe_overwrite_wp;
            return 0;
        fi
    fi

    echo "It doesn't look like a WordPress install, please investigate...";
    exit 1;
}

# Gets confirmation to overwrite existing ./wordpress folder
maybe_overwrite_wp() {
    read -p "Found WordPress $WP_VERS, overwrite? [y/n]: " OVERWRITE_WP;

    if [[ "$OVERWRITE_WP" =~ ^(y|Y|yes|Yes|YES)$ ]]; then
        backup_wordpress_dir;

    elif [[ "$OVERWRITE_WP" =~ ^(n|N|no|No|NO)$ ]]; then
        echo "Exiting...";
        exit 0;

    else
        echo "Invalid input...";
        maybe_overwrite_wp;
    fi
}

# Backs up the ./wordpress folder
backup_wordpress_dir() {
    tar -czf $BACKUP_FILE ./wordpress \
        && rm -rf $WP_DIR \
        && mkdir $WP_DIR \
        && touch $WP_DIR/.gitkeep;

    echo "Backed up existing wordpress content to '$BACKUP_FILE'";
}

# Prompts and downloads the requested wordpress version into ./wordpress
download_wordpress() {
    read -p "Desired WordPress version: " TARGET_WP_VERS;
    TAR_FILE="wordpress-$TARGET_WP_VERS.tar.gz";
    DEST_URI="$WP_DL_BASE$TAR_FILE";
    URI_STATUS=$( \
        curl --write-out '%{http_code}' \
        --silent --output /dev/null \
        --head $DEST_URI \
    );

    if ! [ "$URI_STATUS" -eq 200 ]; then
        echo "$TARGET_WP_VERS is not a valid WordPress version";
        echo "See https://wordpress.org/download/releases/ for available versions";
        revert;
    else
        echo "Downloading...";
        wget -q $DEST_URI;

        echo "Extracting...";
        tar -xzf $TAR_FILE --strip-components=1 -C ./wordpress;

        echo "Cleaning up...";
        rm -rf $TAR_FILE;
    fi
}

# Run the functions
check_existing_wp_install;
download_wordpress;
echo "Done!";
