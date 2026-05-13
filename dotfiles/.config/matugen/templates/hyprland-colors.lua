image = "{{ image }}"
<* for name, value in colors *>
{{ name }} = "{{ value.default.hex | to_color | harmonize: {{ colors.source_color.default.hex_stripped | to_color }} | auto_lightness: 5.0 }}"
<* endfor *>
