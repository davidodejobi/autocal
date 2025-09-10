import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parsed_event.dart';
import '../services/shared_content_handler.dart';
import '../services/text_parser_service.dart';

class SharedContentTestScreen extends ConsumerStatefulWidget {
  const SharedContentTestScreen({super.key});

  @override
  ConsumerState<SharedContentTestScreen> createState() => _SharedContentTestScreenState();
}

class _SharedContentTestScreenState extends ConsumerState<SharedContentTestScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _extractedText;
  ParsedEvent? _parsedEvent;
  String? _errorMessage;

  // Example texts and URLs for testing
  final List<String> _examples = [
    'Meeting tomorrow at 2 PM in Conference Room A',
    'Lunch with Sarah on Friday at 12:30 PM at Cafe Central',
    'https://example.com/event-page',
    'Doctor appointment on Dec 15th at 3:00 PM at 123 Main St',
    'Team standup every Monday at 9 AM via Zoom',
    'Birthday party Saturday 7 PM at John\'s house',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _testParsing() async {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some text or URL to test';
        _extractedText = null;
        _parsedEvent = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _extractedText = null;
      _parsedEvent = null;
    });

    try {
      final inputText = _textController.text.trim();
      final sharedContentHandler = SharedContentHandler();
      final textParser = TextParserService();
      
      String textToParse = inputText;

      // Check if it's a URL and extract content
      if (_isUrl(inputText)) {
        try {
          _extractedText = await sharedContentHandler.extractTextFromUrl(inputText);
          textToParse = _extractedText!;
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to extract text from URL: ${e.toString()}';
            _isLoading = false;
          });
          return;
        }
      } else {
        _extractedText = inputText;
      }

      // Parse the text for event information
      _parsedEvent = await textParser.parseEventFromText(textToParse);

      setState(() {
        _isLoading = false;
      });

      // Scroll to results
      _scrollToResults();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during parsing: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _isUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  void _scrollToResults() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _useExample(String example) {
    _textController.text = example;
  }

  void _clearAll() {
    _textController.clear();
    setState(() {
      _extractedText = null;
      _parsedEvent = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Content Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Shared Content Parsing',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter text or a URL below to test the shared content handling and event parsing functionality. '
                      'URLs will be fetched and their content extracted, then parsed for event information.',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Input section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Text or URL',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter text with event information or a URL to extract content from...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testParsing,
                            icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                            label: Text(_isLoading ? 'Processing...' : 'Test Parsing'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Examples section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Inputs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap any example below to use it:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _examples.map((example) {
                        return ActionChip(
                          label: Text(
                            example.length > 40 ? '${example.substring(0, 40)}...' : example,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _useExample(example),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Results section
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Error',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_extractedText != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.text_fields),
                          const SizedBox(width: 8),
                          Text(
                            'Extracted Text',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _extractedText!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_parsedEvent != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event),
                          const SizedBox(width: 8),
                          Text(
                            'Parsed Event Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEventInfoRow('Title', _parsedEvent!.title),
                      _buildEventInfoRow('Date', _parsedEvent!.date?.toString()),
                      _buildEventInfoRow('Start Time', _parsedEvent!.startTime?.format(context)),
                      _buildEventInfoRow('End Time', _parsedEvent!.endTime?.format(context)),
                      _buildEventInfoRow('Location', _parsedEvent!.location),
                      _buildEventInfoRow('Confidence', '${(_parsedEvent!.confidence * 100).toStringAsFixed(1)}%'),
                      _buildEventInfoRow('Original Text', _parsedEvent!.originalText),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not detected',
              style: TextStyle(
                color: value != null ? null : Colors.grey,
                fontStyle: value != null ? null : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}