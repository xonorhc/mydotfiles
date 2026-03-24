#! /usr/bin/env bash

for theme in '' '-Green' '-Grey' '-Orange' '-Pink' '-Purple' '-Red' '-Teal' '-Yellow'; do
    for color in '' '-Dark'; do
        for type in '' '-Darker' '-Oceanic' '-Palenight'; do
            if [[ "$color" == '' ]]; then
                case "$theme" in
                    '')
                        theme_color='#6182b8'
                        ;;
                    -Green)
                        theme_color='#91b859'
                        ;;
                    -Grey)
                        theme_color='#464b5d'
                        ;;
                    -Orange)
                        theme_color='#f76d47'
                        ;;
                    -Pink)
                        theme_color='#ff5370'
                        ;;
                    -Purple)
                        theme_color='#7c4dff'
                        ;;
                    -Red)
                        theme_color='#e53935'
                        ;;
                    -Teal)
                        theme_color='#39adb5'
                        ;;
                    -Yellow)
                        theme_color='#f6a434'
                        ;;
                esac

                if [[ "$type" == '-Darker' ]]; then
                    background_color='#fafafa'

                    case "$theme" in
                        '')
                            theme_color='#6182b8'
                            ;;
                        -Green)
                            theme_color='#91b859'
                            ;;
                        -Grey)
                            theme_color='#404040'
                            ;;
                        -Orange)
                            theme_color='#f76d47'
                            ;;
                        -Pink)
                            theme_color='#ff5370'
                            ;;
                        -Purple)
                            theme_color='#7c4dff'
                            ;;
                        -Red)
                            theme_color='#e53935'
                            ;;
                        -Teal)
                            theme_color='#39adb5'
                            ;;
                        -Yellow)
                            theme_color='#f6a434'
                            ;;
                    esac
                fi

                if [[ "$type" == '-Oceanic' ]]; then
                    background_color='#fafafa'

                    case "$theme" in
                        '')
                            theme_color='#6182b8'
                            ;;
                        -Green)
                            theme_color='#91b859'
                            ;;
                        -Grey)
                            theme_color='#426367'
                            ;;
                        -Orange)
                            theme_color='#f76d47'
                            ;;
                        -Pink)
                            theme_color='#ff5370'
                            ;;
                        -Purple)
                            theme_color='#7c4dff'
                            ;;
                        -Red)
                            theme_color='#e53935'
                            ;;
                        -Teal)
                            theme_color='#39adb5'
                            ;;
                        -Yellow)
                            theme_color='#f6a434'
                            ;;
                    esac
                fi

                if [[ "$type" == '-Palenight' ]]; then
                    background_color='#fafafa'

                    case "$theme" in
                        '')
                            theme_color='#6182b8'
                            ;;
                        -Green)
                            theme_color='#91b859'
                            ;;
                        -Grey)
                            theme_color='#414863'
                            ;;
                        -Orange)
                            theme_color='#f76d47'
                            ;;
                        -Pink)
                            theme_color='#ff5370'
                            ;;
                        -Purple)
                            theme_color='#7c4dff'
                            ;;
                        -Red)
                            theme_color='#e53935'
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

                if [[ "$type" == '-Darker' ]]; then
                    background_color='#212121'

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

                if [[ "$type" == '-Oceanic' ]]; then
                    background_color='#25363b'

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

                if [[ "$type" == '-Palenight' ]]; then
                    background_color='#292d3e'

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

            if [[ "$type" != '' ]]; then
                cp -r "assets${color}.svg" "assets${theme}${color}${type}.svg"
                if [[ "$color" == '' ]]; then
                    sed -i "s/#6182b8/${theme_color}/g" "assets${theme}${color}${type}.svg"
                else
                    sed -i "s/#82aaff/${theme_color}/g" "assets${theme}${color}${type}.svg"
                fi
            elif [[ "$theme" != '' ]]; then
                cp -r "assets${color}.svg" "assets${theme}${color}.svg"
                if [[ "$color" == '' ]]; then
                    sed -i "s/#6182b8/${theme_color}/g" "assets${theme}${color}.svg"
                else
                    sed -i "s/#82aaff/${theme_color}/g" "assets${theme}${color}.svg"
                fi
            fi

        done
    done
done

echo -e "DONE!"
