import 'package:flutter/material.dart';

class ResearchTopicInput extends StatefulWidget {
  final Function(String topic, String keywords) onSubmit;
  final bool isLoading;

  const ResearchTopicInput({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<ResearchTopicInput> createState() => _ResearchTopicInputState();
}

class _ResearchTopicInputState extends State<ResearchTopicInput> {
  final _topicController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _topicController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _topicController.text.trim(),
        _keywordsController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '연구 시작하기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: '연구 주제',
                  hintText: '연구하고자 하는 주제를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '연구 주제를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keywordsController,
                decoration: const InputDecoration(
                  labelText: '키워드',
                  hintText: '쉼표(,)로 구분하여 키워드를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '키워드를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          '연구 시작하기',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 