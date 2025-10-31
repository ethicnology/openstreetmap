import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtive/core/entities/preferences_entity.dart';
import 'package:furtive/features/preferences/bloc/preferences_bloc.dart';
import 'package:furtive/features/preferences/bloc/preferences_event.dart';
import 'package:furtive/features/preferences/bloc/preferences_state.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesBloc>(
      future: PreferencesBloc.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider.value(
          value: snapshot.data!,
          child: Scaffold(
            appBar: AppBar(title: const Text('Preferences')),
            body: BlocBuilder<PreferencesBloc, PreferencesState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMapThemeSection(context, state),
                    const SizedBox(height: 24),
                    _buildMapLanguageSection(context, state),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<PreferencesBloc>().add(
                            UpdatePreferences(
                              PreferencesEntity(
                                mapTheme: state.preferences.mapTheme,
                                mapLanguage: state.preferences.mapLanguage,
                                accuracyInMeters:
                                    state.preferences.accuracyInMeters,
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapThemeSection(BuildContext context, PreferencesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Map Theme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<MapThemeEntity>(
          value: state.preferences.mapTheme,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              MapThemeEntity.values.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(theme.name.toUpperCase()),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<PreferencesBloc>().add(ChangeMapTheme(value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildMapLanguageSection(
    BuildContext context,
    PreferencesState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Map Language',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<MapLanguageEntity>(
          value: state.preferences.mapLanguage,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              MapLanguageEntity.values.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language.name.toUpperCase()),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<PreferencesBloc>().add(ChangeMapLanguage(value));
            }
          },
        ),
      ],
    );
  }
}
