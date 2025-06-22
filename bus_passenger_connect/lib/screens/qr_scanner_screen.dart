import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';

class QRScannerScreen extends StatefulWidget {
  final String? title;
  final Function(String)? onQRCodeScanned;
  final bool enableBusBoarding;

  const QRScannerScreen({
    super.key,
    this.title,
    this.onQRCodeScanned,
    this.enableBusBoarding = true,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      // Specify QR code format only for focused scanning
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    if (_controller != null) {
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
      _controller!.toggleTorch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan Bus QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (BarcodeCapture capture) {
                if (_hasScanned) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  for (final barcode in barcodes) {
                    final String? code = barcode.rawValue;
                    if (code != null && code.isNotEmpty) {
                      setState(() {
                        _hasScanned = true;
                      });
                      _onQRCodeScanned(code);
                      break;
                    }
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Position the QR code within the scanner frame',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRCodeScanned(String code) async {
    // If custom callback is provided, use it
    if (widget.onQRCodeScanned != null) {
      widget.onQRCodeScanned!(code);
      return;
    }

    // Default behavior: bus boarding
    if (!widget.enableBusBoarding) return;

    try {
      await Provider.of<BusProvider>(context, listen: false).boardBus(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully boarded the bus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasScanned = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
