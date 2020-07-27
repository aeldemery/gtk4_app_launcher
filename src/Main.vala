int main (string[] args) {
    var app_launcher = new Gtk4Demo.AppLauncher ();
    return app_launcher.run (args);
}

public class Gtk4Demo.AppLauncher : Gtk.Application {
    public AppLauncher () {
        Object (
            application_id: "github.aeldemery.gtk4_app_launcher",
            flags : GLib.ApplicationFlags.FLAGS_NONE
        );
    }

    public override void activate () {
        var win = this.active_window;
        if (win == null) {
            win = new AppLauncherWindow (this);
        }
        win.present ();
    }
}

public class Gtk4Demo.AppLauncherWindow : Gtk.ApplicationWindow {
    public AppLauncherWindow (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        /* Create a window and set a few defaults */
        set_default_size (640, 320);
        set_title ("Application Launcher");

        /* We use a #GListStore here, which is a simple array-like list implementation
         * for manual management.
         * List models need to know what type of data they provide, so we need to
         * provide the type here. As we want to do a list of applications, #GAppInfo
         * is the object we provide.
         */
        var app_list = new GLib.ListStore (typeof (GLib.AppInfo));
        var apps = GLib.AppInfo.get_all ();
        foreach (var app in apps) {
            app_list.append (app);
        }

        /* The #GtkListitemFactory is what is used to create #GtkListItems
         * to display the data from the model. So it is absolutely necessary
         * to create one.
         * We will use a #GtkSignalListItemFactory because it is the simplest
         * one to use. Different ones are available for different use cases.
         * The most powerful one is #GtkBuilderListItemFactory which uses
         * #GtkBuilder .ui files, so it requires little code.
         */
        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_listitem_cb);
        factory.bind.connect (bind_listitem_cb);

        /* Create the list widget here.
         * The list will now take items from the model and use the factory
         * to create as many listitems as it needs to show itself to the user.
         */
        var list_view = new Gtk.ListView.with_factory (app_list, factory);

        /* We connect the activate signal here. It's the function we defined
         * above for launching the selected application.
         */
        list_view.activate.connect (activate_cb);

        var scroll_win = new Gtk.ScrolledWindow ();
        this.set_child (scroll_win);
        scroll_win.set_child (list_view);
    }

    /* This is the function we use for setting up new listitems to display.
     * We add just an #GtkImage and a #GtkKabel here to display the application's
     * icon and name, as this is just a simple demo.
     */
    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem item) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

        var image = new Gtk.Image ();
        image.set_icon_size (Gtk.IconSize.LARGE);

        box.append (image);

        var label = new Gtk.Label ("");
        box.append (label);

        item.set_child (box);
    }

    /* Here we need to prepare the listitem for displaying its item. We get the
     * listitem already set up from the previous function, so we can reuse the
     * #GtkImage widget we set up above.
     * We get the item - which we know is a #GAppInfo because it comes out of
     * the model we set up above, grab its icon and display it.
     */
    void bind_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem item) {
        var image = item.get_child ().get_first_child () as Gtk.Image;
        var label = image.get_next_sibling () as Gtk.Label;
        var app_info = item.get_item () as GLib.AppInfo;

        image.set_from_gicon (app_info.get_icon ());
        label.set_label (app_info.get_display_name ());
    }

    /* In more complex code, we would also need functions to unbind and teardown
     * the listitem, but this is simple code, so the default implementations are
     * enough. If we had connected signals, this step would have been necessary.
     *
     * The #GtkSignalListItemFactory documentation contains more information about
     * this step.
     */

    /* This function is called whenever an item in the list is activated. This is
     * the simple way to allow reacting to the Enter key or double-clicking on a
     * listitem.
     * Of course, it is possible to use far more complex interactions by turning
     * off activation and adding buttons or other widgets in the setup function
     * above, but this is a simple demo, so we'll use the simple way.
     */
    void activate_cb (Gtk.ListView list_view, uint position) {
        var app_info = list_view.get_model ().get_item (position) as GLib.AppInfo;

        /* Prepare the context for launching the application and launch it. This
         * code is explained in detail in the documentation for #GdkAppLaunchContext
         * and #GAppInfo.
         */
        var context = list_view.get_display ().get_app_launch_context ();

        try {
            app_info.launch (null, context);
        } catch (GLib.Error error) {
            var error_dialog = new Gtk.MessageDialog (
                list_view.get_root () as Gtk.Window,
                Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE,
                "Could not launch %s", app_info.get_display_name ()
            );
            error_dialog.format_secondary_text ("%s", error.message);
            error_dialog.present ();
        }
    }
}