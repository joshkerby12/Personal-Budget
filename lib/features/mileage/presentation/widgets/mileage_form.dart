import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../helpers/mileage_calculations.dart';
import '../../models/mileage_trip.dart';
import '../providers/mileage_provider.dart';

const List<String> _categoryOptions = <String>[
  'Business - Travel',
  'Business - Client',
  'Business - Other',
];

class MileageForm extends ConsumerStatefulWidget {
  const MileageForm({
    super.key,
    required this.orgId,
    this.initialTrip,
    required this.onClose,
  });

  final String orgId;
  final MileageTrip? initialTrip;
  final VoidCallback onClose;

  @override
  ConsumerState<MileageForm> createState() => _MileageFormState();
}

class _MileageFormState extends ConsumerState<MileageForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _dateController;
  late final TextEditingController _purposeController;
  late final TextEditingController _fromAddressController;
  late final TextEditingController _toAddressController;
  late final TextEditingController _milesController;
  late final TextEditingController _bizPctController;

  late final ValueNotifier<DateTime> _dateNotifier;
  late final ValueNotifier<bool> _roundTripNotifier;
  late final ValueNotifier<String> _categoryNotifier;

  late final bool _isEdit;

  @override
  void initState() {
    super.initState();
    final MileageTrip? trip = widget.initialTrip;
    _isEdit = trip != null;

    final DateTime date = trip?.date ?? DateTime.now();
    _dateNotifier = ValueNotifier<DateTime>(date);
    _roundTripNotifier = ValueNotifier<bool>(trip?.isRoundTrip ?? false);
    _categoryNotifier = ValueNotifier<String>(
      trip != null && _categoryOptions.contains(trip.category)
          ? trip.category
          : _categoryOptions.first,
    );

    _dateController = TextEditingController(text: _formatDate(date));
    _purposeController = TextEditingController(text: trip?.purpose ?? '');
    _fromAddressController = TextEditingController(
      text: trip?.fromAddress ?? '',
    );
    _toAddressController = TextEditingController(text: trip?.toAddress ?? '');
    _milesController = TextEditingController(
      text: trip?.oneWayMiles.toStringAsFixed(1) ?? '',
    );
    _bizPctController = TextEditingController(
      text: ((trip?.bizPct ?? 1.0) * 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _purposeController.dispose();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    _milesController.dispose();
    _bizPctController.dispose();
    _dateNotifier.dispose();
    _roundTripNotifier.dispose();
    _categoryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = ref.watch(mileageControllerProvider).isLoading;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppConstants.spacingLg,
          right: AppConstants.spacingLg,
          top: AppConstants.spacingLg,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom + AppConstants.spacingLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                _isEdit ? 'Edit Trip' : 'Add Trip',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (String? value) => (value == null || value.isEmpty)
                    ? 'Date is required.'
                    : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(labelText: 'Purpose'),
                textInputAction: TextInputAction.next,
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Purpose is required.'
                    : null,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _fromAddressController,
                decoration: const InputDecoration(labelText: 'From Address'),
                textInputAction: TextInputAction.next,
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'From address is required.'
                    : null,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _toAddressController,
                decoration: const InputDecoration(labelText: 'To Address'),
                textInputAction: TextInputAction.next,
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'To address is required.'
                    : null,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _milesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Miles (one way)'),
                validator: (String? value) {
                  final double? miles = double.tryParse(value ?? '');
                  if (miles == null || miles <= 0) {
                    return 'Miles must be greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingSm),
              ValueListenableBuilder<bool>(
                valueListenable: _roundTripNotifier,
                builder: (BuildContext context, bool isRoundTrip, _) {
                  return DropdownButtonFormField<bool>(
                    key: ValueKey<bool>(isRoundTrip),
                    initialValue: isRoundTrip,
                    decoration: const InputDecoration(labelText: 'Round Trip?'),
                    items: const <DropdownMenuItem<bool>>[
                      DropdownMenuItem<bool>(value: false, child: Text('No')),
                      DropdownMenuItem<bool>(value: true, child: Text('Yes')),
                    ],
                    onChanged: (bool? value) {
                      if (value != null) {
                        _roundTripNotifier.value = value;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _bizPctController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Business %'),
                validator: (String? value) {
                  final double? bizPct = double.tryParse(value ?? '');
                  if (bizPct == null || bizPct < 0 || bizPct > 100) {
                    return 'Business % must be between 0 and 100.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingSm),
              ValueListenableBuilder<String>(
                valueListenable: _categoryNotifier,
                builder: (BuildContext context, String category, _) {
                  return DropdownButtonFormField<String>(
                    key: ValueKey<String>(category),
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categoryOptions
                        .map(
                          (String option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (String? value) {
                      if (value != null) {
                        _categoryNotifier.value = value;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              AnimatedBuilder(
                animation: Listenable.merge(<Listenable>[
                  _milesController,
                  _bizPctController,
                  _roundTripNotifier,
                ]),
                builder: (BuildContext context, Widget? child) {
                  final double miles =
                      double.tryParse(_milesController.text) ?? 0;
                  if (miles <= 0) {
                    return const SizedBox.shrink();
                  }

                  final double bizPct =
                      (double.tryParse(_bizPctController.text) ?? 100) / 100;
                  final double total = totalMiles(
                    miles,
                    _roundTripNotifier.value,
                  );
                  final double dedMiles = deductibleMiles(total, bizPct);
                  final double value = deductibleValue(
                    dedMiles,
                    fallbackIrsRatePerMile,
                  );

                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.greenFill,
                      borderRadius: BorderRadius.circular(
                        AppConstants.spacingSm,
                      ),
                    ),
                    child: Text(
                      '\$${value.toStringAsFixed(2)} deductible (${dedMiles.toStringAsFixed(1)} miles)',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.green,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : widget.onClose,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _save,
                      child: Text(_isEdit ? 'Update Trip' : 'Save Trip'),
                    ),
                  ),
                ],
              ),
              if (_isEdit) ...<Widget>[
                const SizedBox(height: AppConstants.spacingSm),
                TextButton(
                  onPressed: isSubmitting ? null : _delete,
                  child: const Text(
                    'Delete Trip',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNotifier.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateNotifier.value = picked;
      _dateController.text = _formatDate(picked);
    }
  }

  Future<void> _save() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final MileageTrip? initialTrip = widget.initialTrip;
    final MileageTrip trip = MileageTrip(
      id: initialTrip?.id ?? '',
      orgId: widget.orgId,
      createdBy: initialTrip?.createdBy ?? '',
      date: _dateNotifier.value,
      purpose: _purposeController.text.trim(),
      fromAddress: _fromAddressController.text.trim(),
      toAddress: _toAddressController.text.trim(),
      oneWayMiles: double.parse(_milesController.text),
      isRoundTrip: _roundTripNotifier.value,
      bizPct: (double.parse(_bizPctController.text) / 100).clamp(0, 1),
      category: _categoryNotifier.value,
      createdAt: initialTrip?.createdAt ?? DateTime.now(),
    );

    try {
      await ref
          .read(mileageControllerProvider.notifier)
          .saveTrip(trip, isEdit: _isEdit);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Trip updated' : 'Trip saved')),
      );
      widget.onClose();
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save trip right now.')),
      );
    }
  }

  Future<void> _delete() async {
    final MileageTrip? trip = widget.initialTrip;
    if (trip == null) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this trip?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref.read(mileageControllerProvider.notifier).deleteTrip(trip.id);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('Trip deleted')));
      widget.onClose();
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to delete trip right now.')),
      );
    }
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
}
