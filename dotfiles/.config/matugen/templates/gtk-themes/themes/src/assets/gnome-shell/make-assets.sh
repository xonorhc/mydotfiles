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
            rm -rf "theme${theme}${type}"
            cp -rf "theme" "theme${theme}${type}"
            sed -i "s/#82aaff/${theme_color_dark}/g" "theme${theme}${type}"/*.svg
            sed -i "s/#6182b8/${theme_color_light}/g" "theme${theme}${type}"/*.svg
        elif [[ "$theme" != '' ]]; then
            rm -rf "theme${theme}"
            cp -rf "theme" "theme${theme}"
            sed -i "s/#82aaff/${theme_color_dark}/g" "theme${theme}"/*.svg
            sed -i "s/#6182b8/${theme_color_light}/g" "theme${theme}"/*.svg
        fi
    done
done

echo -e "DONE!"
