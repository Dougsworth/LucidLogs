import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucidlogs/components/drawer.dart';
import 'package:lucidlogs/components/dream_tile.dart';
import 'package:lucidlogs/models/dream.dart';
import 'package:lucidlogs/models/dream_db.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DreamsPage extends StatefulWidget {
  const DreamsPage({super.key});

  @override
  State<DreamsPage> createState() => _DreamsPageState();
}

class _DreamsPageState extends State<DreamsPage> {
  final textController = TextEditingController();

  String formatDate(DateTime dt) {
    final DateFormat dateTime = DateFormat('dd-MM-yyyy HH:mm');
    return dateTime.format(dt);
  }

  void createDream() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: "Enter your dream..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await context.read<DreamDatabase>().addDream(textController.text);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Log Dream"),
          ),
        ],
      ),
    );
  }

  void updateDream(Dream dream) {
    textController.text = dream.content;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Modify Dream"),
        content: TextField(controller: textController),
        actions: [
          TextButton(
            onPressed: () {
              context
                  .read<DreamDatabase>()
                  .updateDream(dream.id, textController.text);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  void deleteDream(int id) {
    context.read<DreamDatabase>().deleteDream(id);
  }

  void analyzeDream(Dream dream) async {
    final dreamDatabase = context.read<DreamDatabase>();
    final analysis = await dreamDatabase.sendDreamToBackend(dream.content);

    // Display the analysis in a dialog or any other way you'd like
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dream Analysis"),
        content: Text(analysis),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    readDreams();
  }

  void readDreams() {
    context.read<DreamDatabase>().getDreams();
  }

  @override
  Widget build(BuildContext context) {
    final dreamDatabase = context.watch<DreamDatabase>();
    List<Dream> currentDreams = dreamDatabase.currentDreams;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dreams", style: GoogleFonts.dmSerifText(fontSize: 36.0)),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createDream,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentDreams.length,
              itemBuilder: (context, index) {
                final dream = currentDreams[index];
                return ListTile(
                  title: Text(dream.content),
                  subtitle: Text(formatDate(dream.createdAt)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => updateDream(dream),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteDream(dream.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons
                            .cloud_upload), // Icon to trigger backend request
                        onPressed: () => analyzeDream(
                            dream), // Send dream to backend for analysis
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
