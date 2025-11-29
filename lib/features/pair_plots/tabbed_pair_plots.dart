// tabbed_pair_plots.dart
import 'package:flutter/material.dart';
import '../../../core/data/data_model.dart';
import '../marketing/configs/grouped_marketing_campaign_pair_plot_config.dart';
import 'pair_plot_config.dart';
import 'pair_plot_group.dart';
import 'pair_plot_widget.dart';
import 'grouped_pair_plot_config.dart';
import 'grouped_config_wrapper.dart';

class TabbedPairPlots<T extends DataModel> extends StatefulWidget {
  final List<T> data;
  final PairPlotConfig<T> config;

  const TabbedPairPlots({
    super.key,
    required this.data,
    required this.config,
  });

  @override
  State<TabbedPairPlots> createState() => _TabbedPairPlotsState<T>();
}

class _TabbedPairPlotsState<T extends DataModel> extends State<TabbedPairPlots<T>> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final groups = _getGroups();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: groups.asMap().entries.map((entry) {
                final index = entry.key;
                final group = entry.value;
                final isSelected = _selectedTabIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(group.title),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Контент выбранной группы
        Expanded(
          child: UniversalPairPlots<T>(
            data: widget.data,
            config: GroupedPairPlotConfigWrapper<T>(
              originalConfig: widget.config,
              groupFeatures: groups[_selectedTabIndex].features,
            ),
            title: groups[_selectedTabIndex].title,
            colorField: 'response', 
          ),
        ),
      ],
    );
  }

  List<PairPlotGroup> _getGroups() {
    if (widget.config is GroupedHeartAttackPairPlotConfig) {
      return (widget.config as GroupedHeartAttackPairPlotConfig).groups;
    }
    if (widget.config is GroupedMarketingCampaignPairPlotConfig) {
      return (widget.config as GroupedMarketingCampaignPairPlotConfig).groups;
    }
    return [
      PairPlotGroup(
        title: 'Все признаки',
        features: widget.config.features,
      ),
    ];
  }
}