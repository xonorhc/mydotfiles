make_gtkrc() {
    local dest="${1}"
    local name="${2}"
    local theme="${3}"
    local color="${4}"
    local size="${5}"
    local ctype="${6}"
    local window="${7}"

    [[ "${color}" == '-Light' ]] && local ELSE_LIGHT="${color}"
    [[ "${color}" == '-Dark' ]] && local ELSE_DARK="${color}"

    local GTKRC_DIR="${SRC_DIR}/main/gtk-2.0"
    local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

    if [[ "${color}" != '-Dark' ]]; then
        case "$theme" in
            '')
                theme_color='#6182b8'
                ;;
            -Green)
                theme_color='#91b859'
                ;;
            -Grey)
                theme_color='#585e74'
                ;;
            -Orange)
                theme_color='#f6a434'
                ;;
            -Pink)
                theme_color='#ff5370'
                ;;
            -Purple)
                theme_color='#7c4dff'
                ;;
            -Red)
                theme_color='#ff5370'
                ;;
            -Teal)
                theme_color='#39adb5'
                ;;
            -Yellow)
                theme_color='#f6a434'
                ;;
        esac

        if [[ "$ctype" == '-Darker' ]]; then
            case "$theme" in
                '')
                    theme_color='#6182b8'
                    ;;
                -Green)
                    theme_color='#91b859'
                    ;;
                -Grey)
                    theme_color='#515151'
                    ;;
                -Orange)
                    theme_color='#f6a434'
                    ;;
                -Pink)
                    theme_color='#ff5370'
                    ;;
                -Purple)
                    theme_color='#7c4dff'
                    ;;
                -Red)
                    theme_color='#ff5370'
                    ;;
                -Teal)
                    theme_color='#39adb5'
                    ;;
                -Yellow)
                    theme_color='#f6a434'
                    ;;
            esac
        fi

        if [[ "$ctype" == '-Oceanic' ]]; then
            case "$theme" in
                '')
                    theme_color='#6182b8'
                    ;;
                -Green)
                    theme_color='#91b859'
                    ;;
                -Grey)
                    theme_color='#546e7a'
                    ;;
                -Orange)
                    theme_color='#f6a434'
                    ;;
                -Pink)
                    theme_color='#ff5370'
                    ;;
                -Purple)
                    theme_color='#7c4dff'
                    ;;
                -Red)
                    theme_color='#ff5370'
                    ;;
                -Teal)
                    theme_color='#39adb5'
                    ;;
                -Yellow)
                    theme_color='#f6a434'
                    ;;
            esac
        fi

        if [[ "$ctype" == '-Palenight' ]]; then
            case "$theme" in
                '')
                    theme_color='#6182b8'
                    ;;
                -Green)
                    theme_color='#91b859'
                    ;;
                -Grey)
                    theme_color='#515772'
                    ;;
                -Orange)
                    theme_color='#f6a434'
                    ;;
                -Pink)
                    theme_color='#ff5370'
                    ;;
                -Purple)
                    theme_color='#7c4dff'
                    ;;
                -Red)
                    theme_color='#ff5370'
                    ;;
                -Teal)
                    theme_color='#39adb5'
                    ;;
                -Yellow)
                    theme_color='#f6a434'
                    ;;
            esac
        fi
    else
        case "$theme" in
            '')
                theme_color='#82aaff'
                ;;
            -Green)
                theme_color='#c3e88d'
                ;;
            -Grey)
                theme_color='#d3e1e8'
                ;;
            -Orange)
                theme_color='#f78c6c'
                ;;
            -Pink)
                theme_color='#ff9cac'
                ;;
            -Purple)
                theme_color='#c792ea'
                ;;
            -Red)
                theme_color='#f07178'
                ;;
            -Teal)
                theme_color='#89ddff'
                ;;
            -Yellow)
                theme_color='#ffcb6b'
                ;;
        esac

        if [[ "$ctype" == '-Darker' ]]; then
            case "$theme" in
                '')
                    theme_color='#82aaff'
                    ;;
                -Green)
                    theme_color='#c3e88d'
                    ;;
                -Grey)
                    theme_color='#d3e1e8'
                    ;;
                -Orange)
                    theme_color='#f78c6c'
                    ;;
                -Pink)
                    theme_color='#ff9cac'
                    ;;
                -Purple)
                    theme_color='#c792ea'
                    ;;
                -Red)
                    theme_color='#f07178'
                    ;;
                -Teal)
                    theme_color='#89ddff'
                    ;;
                -Yellow)
                    theme_color='#ffcb6b'
                    ;;
            esac
        fi

        if [[ "$ctype" == '-Oceanic' ]]; then
            case "$theme" in
                '')
                    theme_color='#82aaff'
                    ;;
                -Green)
                    theme_color='#c3e88d'
                    ;;
                -Grey)
                    theme_color='#d3e1e8'
                    ;;
                -Orange)
                    theme_color='#f78c6c'
                    ;;
                -Pink)
                    theme_color='#ff9cac'
                    ;;
                -Purple)
                    theme_color='#c792ea'
                    ;;
                -Red)
                    theme_color='#f07178'
                    ;;
                -Teal)
                    theme_color='#89ddff'
                    ;;
                -Yellow)
                    theme_color='#ffcb6b'
                    ;;
            esac
        fi

        if [[ "$ctype" == '-Palenight' ]]; then
            case "$theme" in
                '')
                    theme_color='#82aaff'
                    ;;
                -Green)
                    theme_color='#c3e88d'
                    ;;
                -Grey)
                    theme_color='#d3e1e8'
                    ;;
                -Orange)
                    theme_color='#f78c6c'
                    ;;
                -Pink)
                    theme_color='#ff9cac'
                    ;;
                -Purple)
                    theme_color='#c792ea'
                    ;;
                -Red)
                    theme_color='#f07178'
                    ;;
                -Teal)
                    theme_color='#89ddff'
                    ;;
                -Yellow)
                    theme_color='#ffcb6b'
                    ;;
            esac
        fi
    fi

    if [[ "$blackness" == 'true' ]]; then
        case "$ctype" in
            '')
                background_light='#fafafa'
                background_dark='#090b10'
                background_darker='#1a1c25'
                background_alt='#232637'
                titlebar_light='#fafafa'
                titlebar_dark='#090b10'
                ;;
            -Darker)
                background_light='#fafafa'
                background_dark='#0a0a0a'
                background_darker='#141414'
                background_alt='#1a1a1a'
                titlebar_light='#fafafa'
                titlebar_dark='#0a0a0a'
                ;;
            -Oceanic)
                background_light='#fafafa'
                background_dark='#1e272c'
                background_darker='#1c2c30'
                background_alt='#263b40'
                titlebar_light='#fafafa'
                titlebar_dark='#1e272c'
                ;;
            -Palenight)
                background_light='#fafafa'
                background_dark='#1b1e2b'
                background_darker='#202331'
                background_alt='#282c3e'
                titlebar_light='#fafafa'
                titlebar_dark='#1b1e2b'
                ;;
        esac
    else
        case "$ctype" in
            '')
                titlebar_light='#fafafa'
                background_dark='#0f111a'
                background_darker='#3b3f51'
                background_alt='#464b5d'
                titlebar_light='#fafafa'
                titlebar_dark='#0f111a'
                ;;
            -Darker)
                titlebar_light='#fafafa'
                background_dark='#212121'
                background_darker='#323232'
                background_alt='#3f3f3f'
                titlebar_light='#fafafa'
                titlebar_dark='#212121'
                ;;
            -Oceanic)
                titlebar_light='#fafafa'
                background_dark='#25363b'
                background_darker='#314549'
                background_alt='#355058'
                titlebar_light='#fafafa'
                titlebar_dark='#25363b'
                ;;
            -Palenight)
                titlebar_light='#fafafa'
                background_dark='#292d3e'
                background_darker='#3a3f58'
                background_alt='#364367'
                titlebar_light='#fafafa'
                titlebar_dark='#292d3e'
                ;;
        esac
    fi

    mkdir -p "${THEME_DIR}/gtk-2.0"

    cp -r "${GTKRC_DIR}/gtkrc${ELSE_DARK:-}-default" "${THEME_DIR}/gtk-2.0/gtkrc"
    sed -i "s/#fafafa/${background_light}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
    sed -i "s/#0f111a/${background_dark}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
    sed -i "s/#3b3f51/${background_alt}/g" "${THEME_DIR}/gtk-2.0/gtkrc"

    if [[ "${color}" == '-Dark' ]]; then
        sed -i "s/#82aaff/${theme_color}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
        sed -i "s/#090b10/${background_darker}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
        sed -i "s/#090b10/${titlebar_dark}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
    else
        sed -i "s/#6182b8/${theme_color}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
        sed -i "s/#fafafa/${titlebar_light}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
    fi
}
