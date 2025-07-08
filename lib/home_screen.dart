import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fd_downloader/services/downloader_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Plataforma { youtube, instagram, tiktok }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final _downloaderService = DownloaderService();
  final bool _isDownloading = false;
  Plataforma _selectedPlataforma = Plataforma.youtube;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<Plataforma>> _buildPlataformaItem() {
    return Plataforma.values.map((e) {
      return DropdownMenuItem<Plataforma>(
        value: e,
        child: Row(
          children: [
            Icon(
              e == Plataforma.youtube
                  ? FontAwesomeIcons.youtube
                  : e == Plataforma.tiktok
                  ? FontAwesomeIcons.tiktok
                  : FontAwesomeIcons.instagram,
            ),
            const SizedBox(width: 10),
            Text(e.name, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPlataformDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Plataforma", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 5),
        DropdownButtonFormField2<Plataforma>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            direction: DropdownDirection.textDirection,
          ),
          value: _selectedPlataforma,
          items: _buildPlataformaItem(),
          onChanged: (plataforma) {
            setState(() {
              _selectedPlataforma = plataforma!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUrlTextFormField() {
    return TextField(
      controller: _urlController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: Icon(FontAwesomeIcons.link, size: 20),
        labelText: "URL del video",
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(0, 48), // Height
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () async =>
            await _downloaderService.downloadReel(_urlController.text),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(FontAwesomeIcons.download, size: 20),
            const SizedBox(width: 10),
            Text("Descargar", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(FontAwesomeIcons.vihara),
        title: Text(
          "Fd Downloader",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(FontAwesomeIcons.download, size: 40),
                ),
                SizedBox(height: 12),
                Text(
                  "Descarga video facilemente!",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25),
                _buildPlataformDropDown(),
                SizedBox(height: 50),
                _buildUrlTextFormField(),
                SizedBox(height: 50),
                _buildDownloadButton(),
                SizedBox(height: 25),
                if (_isDownloading)
                  Text(
                    "Descargando...",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
