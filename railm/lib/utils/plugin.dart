abstract class Plugin {
    final String name;
    final String description;

    Plugin(this.name, this.description);

    Future<num> fetch();
}
