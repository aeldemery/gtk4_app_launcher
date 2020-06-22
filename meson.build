project (
    'github.aeldemery.gtk4_app_launcher',
    'c', 'vala',
    version: '0.1.0'
)

sources = files (
    'src/Main.vala',
)

dependencies = [
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('gtk4'),
]

executable (
    meson.project_name(),
    sources: sources,
    dependencies: dependencies,
    install: true
)