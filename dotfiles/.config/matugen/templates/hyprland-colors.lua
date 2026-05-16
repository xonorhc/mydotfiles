image = "{{ image }}"
<* for name, value in colors *>
{{ name }} = "{{ value.default.hex | harmonize: {{ colors.source_color.default.hex | to_color }} | auto_lightness: 5.0 }}"
<* endfor *>
