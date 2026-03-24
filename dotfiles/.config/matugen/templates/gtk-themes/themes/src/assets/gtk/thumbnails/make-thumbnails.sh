#! /usr/bin/env bash

for theme in '' '-Blue' '-Green' '-Grey' '-Orange' '-Pink' '-Purple' '-Red' '-Teal' '-Yellow'; do
    for type in '' '-Darker' '-Oceanic' '-Palenight'; do
        case "$theme" in
            '')
                theme_color_dark='#82aaff'
                theme_color_light='#6182b8'
                ;;
            -Blue)
                theme_color_dark='#82aaff'
                theme_color_light='#6182b8'
                ;;
            -Green)
                theme_color_dark='#c3e88d'
                theme_color_light='#91b859'
                ;;
            -Grey)
                theme_color_dark='#d3e1e8'
                theme_color_light='#585e74'
                ;;
            -Orange)
                theme_color_dark='#f78c6c'
                theme_color_light='#f76d47'
                ;;
            -Pink)
                theme_color_dark='#ff9cac'
                theme_color_light='#ff5370'
                ;;
            -Purple)
                theme_color_dark='#c792ea'
                theme_color_light='#7c4dff'
                ;;
            -Red)
                theme_color_dark='#f07178'
                theme_color_light='#e53935'
                ;;
            -Teal)
                theme_color_dark='#89ddff'
                theme_color_light='#39adb5'
                ;;
            -Yellow)
                theme_color_dark='#f6a434'
                theme_color_light='#ffcb6b'
                ;;
        esac

        if [[ "$type" == '-Darker' ]]; then
            background_light='#fafafa'
            background_dark='#212121'
            base_dark='#1a1a1a'
            surface_dark='#323232'

            case "$theme" in
                '')
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Blue)
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Green)
                    theme_color_dark='#c3e88d'
                    theme_color_light='#91b859'
                    ;;
                -Grey)
                    theme_color_dark='#d3e1e8'
                    theme_color_light='#515151'
                    ;;
                -Orange)
                    theme_color_dark='#f78c6c'
                    theme_color_light='#f76d47'
                    ;;
                -Pink)
                    theme_color_dark='#ff9cac'
                    theme_color_light='#ff5370'
                    ;;
                -Purple)
                    theme_color_dark='#c792ea'
                    theme_color_light='#7c4dff'
                    ;;
                -Red)
                    theme_color_dark='#f07178'
                    theme_color_light='#e53935'
                    ;;
                -Teal)
                    theme_color_dark='#89ddff'
                    theme_color_light='#39adb5'
                    ;;
                -Yellow)
                    theme_color_dark='#f6a434'
                    theme_color_light='#ffcb6b'
                    ;;
            esac
        fi

        if [[ "$type" == '-Oceanic' ]]; then
            background_light='#fafafa'
            background_dark='#25363b'
            base_dark='#1c2c30'
            surface_dark='#314549'

            case "$theme" in
                '')
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Blue)
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Green)
                    theme_color_dark='#c3e88d'
                    theme_color_light='#91b859'
                    ;;
                -Grey)
                    theme_color_dark='#d3e1e8'
                    theme_color_light='#546e7a'
                    ;;
                -Orange)
                    theme_color_dark='#f78c6c'
                    theme_color_light='#f76d47'
                    ;;
                -Pink)
                    theme_color_dark='#ff9cac'
                    theme_color_light='#ff5370'
                    ;;
                -Purple)
                    theme_color_dark='#c792ea'
                    theme_color_light='#7c4dff'
                    ;;
                -Red)
                    theme_color_dark='#f07178'
                    theme_color_light='#e53935'
                    ;;
                -Teal)
                    theme_color_dark='#89ddff'
                    theme_color_light='#39adb5'
                    ;;
                -Yellow)
                    theme_color_dark='#f6a434'
                    theme_color_light='#ffcb6b'
                    ;;
            esac
        fi

        if [[ "$type" == '-Palenight' ]]; then
            background_light='#fafafa'
            background_dark='#292d3e'
            base_dark='#202331'
            surface_dark='#3a3f58'

            case "$theme" in
                '')
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Blue)
                    theme_color_dark='#82aaff'
                    theme_color_light='#6182b8'
                    ;;
                -Green)
                    theme_color_dark='#c3e88d'
                    theme_color_light='#91b859'
                    ;;
                -Grey)
                    theme_color_dark='#d3e1e8'
                    theme_color_light='#515772'
                    ;;
                -Orange)
                    theme_color_dark='#f78c6c'
                    theme_color_light='#f76d47'
                    ;;
                -Pink)
                    theme_color_dark='#ff9cac'
                    theme_color_light='#ff5370'
                    ;;
                -Purple)
                    theme_color_dark='#c792ea'
                    theme_color_light='#7c4dff'
                    ;;
                -Red)
                    theme_color_dark='#f07178'
                    theme_color_light='#e53935'
                    ;;
                -Teal)
                    theme_color_dark='#89ddff'
                    theme_color_light='#39adb5'
                    ;;
                -Yellow)
                    theme_color_dark='#f6a434'
                    theme_color_light='#ffcb6b'
                    ;;
            esac
        fi

        if [[ "$type" != '' ]]; then
            rm -rf "thumbnail${theme}${type}.svg"
            cp -rf "thumbnail.svg" "thumbnail${theme}${type}.svg"
            sed -i "s/#82aaff/${theme_color_dark}/g" "thumbnail${theme}${type}.svg"
            sed -i "s/#6182b8/${theme_color_light}/g" "thumbnail${theme}${type}.svg"
            sed -i "s/#fafafa/${background_light}/g" "thumbnail${theme}${type}.svg"
            sed -i "s/#0f111a/${background_dark}/g" "thumbnail${theme}${type}.svg"
            sed -i "s/thumbnail/thumbnail${theme}${type}/g" "thumbnail${theme}${type}.svg"
        elif [[ "$theme" != '' ]]; then
            rm -rf "thumbnail${theme}.svg"
            cp -rf "thumbnail.svg" "thumbnail${theme}.svg"
            sed -i "s/#82aaff/${theme_color_dark}/g" "thumbnail${theme}.svg"
            sed -i "s/#6182b8/${theme_color_light}/g" "thumbnail${theme}.svg"
            sed -i "s/thumbnail/thumbnail${theme}/g" "thumbnail${theme}.svg"
        fi
    done
done

echo -e "DONE!"
