import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fd_downloader/providers/download_progress_provider.dart';
import 'package:fd_downloader/services/downloader_service.dart';
import 'package:fd_downloader/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final _downloaderService = DownloaderService();
  bool _isDownloading = false;
  Plataforma _selectedPlataforma = Plataforma.youtube;
  FileType _selectedFileType = FileType.video;

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
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: IconButton(
          onPressed: () async {
            _urlController.clear();
            ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
            setState(() {
              _urlController.text = data != null ? data.text! : "";
            });
          },
          icon: Icon(FontAwesomeIcons.link, size: 20),
        ),
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
        onPressed: () async {
          setState(() {
            _isDownloading = true;
          });
          try {
            switch (_selectedPlataforma) {
              case Plataforma.youtube:
                await _downloaderService.downloadYoutubeVideo(
                  _urlController.text,
                  ref,
                  _selectedFileType,
                );
              case Plataforma.tiktok:
                await _downloaderService.downloadTiktok(
                  _urlController.text,
                  ref,
                );
                break;
              case Plataforma.instagram:
                await _downloaderService.downloadReel(_urlController.text, ref);
                break;
            }
            if (!mounted) return;
            SnackbarHelper.showCustomSnackbar(
              context: context,
              message: "Descarga completada",
              type: SnackbarType.success,
            );
          } catch (e) {
            if (!mounted) return;

            final errorMsg = e.toString().replaceAll("Exception: ", "");
            SnackbarHelper.showCustomSnackbar(
              context: context,
              message: errorMsg,
              type: SnackbarType.error,
            );
          } finally {
            setState(() {
              _isDownloading = false;
            });
            ref.read(downloadProgressProvider.notifier).reset();
          }
        },
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

  Widget _buildDownloadProgress() {
    return Consumer(
      builder: (context, ref, _) {
        final progress = ref.watch(downloadProgressProvider);

        // Check if download is complete and trigger setState
        if (progress >= 100) {
          // Delay until after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Avoid calling setState if widget is disposed
            if (context.mounted) {
              setState(() {
                _isDownloading = false;
              });

              // Reset the provider
              ref.read(downloadProgressProvider.notifier).reset();
            }
          });
        }

        return Column(
          children: [
            Text(
              progress == 0 ? "Preparando descarga..." : "Descargando...",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text("${progress.toStringAsFixed(0)}%"),
          ],
        );
      },
    );
  }

  Widget _buildFileTypeSelection() {
    return Row(
      children: [
        RadioMenuButton(
          value: FileType.video,
          groupValue: _selectedFileType,
          onChanged: (FileType? value) {
            setState(() {
              _selectedFileType = FileType.video;
            });
          },
          child: Text("Video", style: Theme.of(context).textTheme.bodyMedium),
        ),
        RadioMenuButton(
          value: FileType.audio,
          groupValue: _selectedFileType,
          onChanged: (FileType? value) {
            setState(() {
              _selectedFileType = FileType.audio;
            });
          },
          child: Text("Audio", style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
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
                if (_selectedPlataforma == Plataforma.youtube)
                  _buildFileTypeSelection(),
                SizedBox(height: 50),
                _buildUrlTextFormField(),
                SizedBox(height: 50),
                _buildDownloadButton(),
                SizedBox(height: 25),
                if (_isDownloading) _buildDownloadProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
