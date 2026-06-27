import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Map<String, dynamic> activityData;

  const ActivityDetailScreen({super.key, required this.activityData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Extract data
    final problemName = _stringValue(activityData, ['problemTitle', 'problemName', 'title']) ?? 'Untitled Problem';
    final problemId = _stringValue(activityData, ['problemId', 'id', 'documentId']) ?? 'Unknown ID';
    final difficulty = _stringValue(activityData, ['difficulty', 'level']) ?? 'Unknown';
    final platform = _stringValue(activityData, ['platform', 'source']) ?? 'Unknown platform';
    final problemStatement = _stringValue(activityData, ['description', 'problemStatement', 'statement', 'prompt']) ?? 'No problem statement provided.';
    final code = _stringValue(activityData, ['codeSnippet', 'solutionCode', 'submittedSolution', 'code']) ?? 'No code available.';
    final status = _stringValue(activityData, ['status', 'submissionStatus', 'result']) ?? 'Unknown';
    final timestamp = _parseTimestamp(activityData['timestamp'] ?? activityData['submittedAt']);
    final executionTime = _stringValue(activityData, ['executionTime', 'runtime', 'time']);
    final memoryUsage = _stringValue(activityData, ['memoryUsage', 'memory']);
    final passedTests = _stringValue(activityData, ['testCasesPassed', 'passedTestCases', 'passed']);
    final failedTests = _stringValue(activityData, ['testCasesFailed', 'failedTestCases', 'failed']);
    
    // Extract additional fields with proper categorization
    final tags = _extractTags(activityData);
    
    // Debug: Print all keys to find approach data
    debugPrint('All keys in activityData: ${activityData.keys}');
    
    // Try multiple variations for approach
    String? approach = _stringValue(activityData, [
      'approach', 
      'solutionApproach', 
      'method', 
      'approach_description',
      'solution',
      'explanation',
      'solutionDescription',
      'approachText'
    ]);
    
    // If approach is null, try to find it in nested objects
    if (approach == null) {
      for (var key in activityData.keys) {
        if (key.toLowerCase().contains('approach') || 
            key.toLowerCase().contains('solution') || 
            key.toLowerCase().contains('explanation')) {
          final value = activityData[key];
          if (value is String && value.isNotEmpty) {
            approach = value;
            debugPrint('Found approach in key: $key');
            break;
          }
        }
      }
    }
    
    // If still null, check for a 'data' field that might contain the approach
    if (approach == null && activityData['data'] != null) {
      final dataMap = activityData['data'] as Map<String, dynamic>?;
      if (dataMap != null) {
        approach = _stringValue(dataMap, [
          'approach', 
          'solutionApproach', 
          'method', 
          'explanation',
          'solution'
        ]);
        if (approach != null) {
          debugPrint('Found approach in data field');
        }
      }
    }
    
    debugPrint('Approach value: $approach');
    
    final timeComplexity = _stringValue(activityData, ['timeComplexity', 'time_complexity', 'complexity', 'timeComplexity']);
    final spaceComplexity = _stringValue(activityData, ['spaceComplexity', 'space_complexity', 'spaceComplexity']);
    final views = _stringValue(activityData, ['views', 'viewCount', 'view_count']);
    final likes = _stringValue(activityData, ['likes', 'likeCount', 'like_count']);
    final comments = _stringValue(activityData, ['comments', 'commentCount', 'comment_count']);
    final problemLink = _stringValue(activityData, ['problemLink', 'link', 'url', 'problem_url']);
    
    debugPrint('Problem Link: $problemLink');
    
    final statusInfo = _getStatusInfo(status, theme.colorScheme);
    final difficultyColor = _getDifficultyColor(difficulty, theme.colorScheme);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, problemName),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              _buildStatusBanner(status, statusInfo, context),
              const SizedBox(height: 16),

              // Problem Header with Clickable Link
              _buildProblemHeader(
                problemName, 
                difficulty, 
                difficultyColor, 
                platform, 
                problemId, 
                timestamp,
                problemLink,
                context,
              ),
              const SizedBox(height: 12),

              // Tags Section
              if (tags.isNotEmpty) ...[
                _buildTagsSection(tags, context),
                const SizedBox(height: 16),
              ],

              // Quick Stats
              _buildQuickStats(executionTime, memoryUsage, passedTests, failedTests, context),
              const SizedBox(height: 20),

              // Problem Statement
              _buildSectionTitle('Problem Statement', Icons.description_outlined, context),
              const SizedBox(height: 8),
              _buildStatementCard(problemStatement, context),
              const SizedBox(height: 20),

              // Approach Section
              _buildSectionTitle('Approach', Icons.lightbulb_outline, context),
              const SizedBox(height: 8),
              _buildApproachCard(approach, context),
              const SizedBox(height: 20),

              // Complexity
              if (timeComplexity != null || spaceComplexity != null) ...[
                _buildSectionTitle('Complexity', Icons.analytics_outlined, context),
                const SizedBox(height: 8),
                _buildComplexityCard(timeComplexity, spaceComplexity, context),
                const SizedBox(height: 20),
              ],

              // Solution Code
              _buildSectionTitle('Solution', Icons.code_outlined, context),
              const SizedBox(height: 8),
              _buildCodeCard(code, context),
              const SizedBox(height: 20),

              // Social Stats (Views, Likes, Comments)
              if (views != null || likes != null || comments != null) ...[
                _buildSocialStats(views, likes, comments, context),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String problemName) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.colorScheme.onSurface),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        problemName,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
    );
  }

  Widget _buildStatusBanner(String status, StatusInfo statusInfo, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusInfo.icon, color: statusInfo.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo.label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: statusInfo.color,
                  ),
                ),
                Text(
                  statusInfo.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: statusInfo.color.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemHeader(
    String name, 
    String difficulty, 
    Color difficultyColor, 
    String platform,
    String problemId,
    DateTime? timestamp,
    String? problemLink,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final hasValidLink = problemLink != null && problemLink.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  difficulty,
                  style: GoogleFonts.inter(
                    color: difficultyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, size: 14, color: theme.colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      platform,
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clickable Problem Name
          InkWell(
            onTap: () {
              if (hasValidLink) {
                _launchURL(problemLink!, context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No problem link available'),
                    backgroundColor: theme.colorScheme.secondary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.2,
                      color: hasValidLink
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      decoration: hasValidLink ? TextDecoration.underline : null,
                      decorationColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                ),
                if (hasValidLink) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.fingerprint, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'ID: $platform-$problemId',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Submitted ${timestamp != null ? DateFormat.MMMd().format(timestamp) : 'Unknown date'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(List<String> tags, BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.secondaryContainer,
                theme.colorScheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                tag,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickStats(
    String? executionTime, 
    String? memoryUsage, 
    String? passedTests, 
    String? failedTests, 
    BuildContext context,
  ) {
    final hasData = executionTime != null || memoryUsage != null || passedTests != null || failedTests != null;
    
    if (!hasData) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final List<Map<String, dynamic>> stats = [];
    if (executionTime != null) {
      stats.add({
        'icon': Icons.speed_outlined,
        'value': executionTime,
        'label': 'Runtime',
        'color': theme.colorScheme.primary,
      });
    }
    if (memoryUsage != null) {
      stats.add({
        'icon': Icons.memory_outlined,
        'value': memoryUsage,
        'label': 'Memory',
        'color': theme.colorScheme.tertiary,
      });
    }
    if (passedTests != null) {
      stats.add({
        'icon': Icons.check_circle_outline,
        'value': passedTests,
        'label': 'Passed',
        'color': theme.colorScheme.secondary,
      });
    }
    if (failedTests != null) {
      stats.add({
        'icon': Icons.error_outline,
        'value': failedTests,
        'label': 'Failed',
        'color': theme.colorScheme.error,
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.36)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return _buildQuickStatItem(
            context: context,
            icon: stat['icon'] as IconData,
            value: stat['value'] as String,
            label: stat['label'] as String,
            color: stat['color'] as Color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatementCard(String statement, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.36)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        statement,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildApproachCard(String? approach, BuildContext context) {
    final theme = Theme.of(context);
    if (approach == null || approach.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.36)),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant, size: 32),
            const SizedBox(height: 8),
            Text(
              'No approach description available',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check your data structure for fields like "approach", "solution", or "explanation"',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondaryContainer,
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.lightbulb, size: 20, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              approach,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexityCard(String? timeComplexity, String? spaceComplexity, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.36)),
      ),
      child: Row(
        children: [
          if (timeComplexity != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⏱️ Time',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeComplexity,
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (spaceComplexity != null) ...[
            if (timeComplexity != null) 
              Container(
                width: 1,
                height: 30,
                color: theme.colorScheme.outline.withOpacity(0.75),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💾 Space',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spaceComplexity,
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeCard(String code, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Dart',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                height: 1.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialStats(String? views, String? likes, String? comments, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.36)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (views != null)
            _buildSocialStatItem(
              context: context,
              icon: Icons.visibility_outlined,
              value: views,
              label: 'Views',
            ),
          if (likes != null)
            _buildSocialStatItem(
              context: context,
              icon: Icons.favorite_outline,
              value: likes,
              label: 'Likes',
              color: theme.colorScheme.error,
            ),
          if (comments != null)
            _buildSocialStatItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              value: comments,
              label: 'Comments',
            ),
        ],
      ),
    );
  }

  Widget _buildSocialStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 22, color: color ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Helper methods
  static String? _stringValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
      if (value is bool) return value ? 'Yes' : 'No';
      if (value is DateTime) return DateFormat.yMMMMd().add_jm().format(value.toLocal());
      if (value is Timestamp) return DateFormat.yMMMMd().add_jm().format(value.toDate().toLocal());
    }
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<String> _extractTags(Map<String, dynamic> source) {
    final tags = <String>[];
    
    // Check for tags field
    final tagValue = source['tags'] ?? source['tag'] ?? source['topics'];
    if (tagValue != null) {
      if (tagValue is List) {
        for (final item in tagValue) {
          if (item is String && item.isNotEmpty) {
            tags.add(item);
          }
        }
      } else if (tagValue is String && tagValue.isNotEmpty) {
        // Split by comma if it's a string
        tags.addAll(tagValue.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty));
      }
    }
    
    // Also check for individual tag fields
    for (final key in ['tag1', 'tag2', 'tag3', 'topic1', 'topic2', 'topic3']) {
      final value = source[key];
      if (value is String && value.isNotEmpty) {
        tags.add(value);
      }
    }
    
    return tags.take(5).toList(); // Limit to 5 tags
  }

  static Future<void> _launchURL(String url, BuildContext context) async {
    final theme = Theme.of(context);
    if (url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No URL provided'),
            backgroundColor: theme.colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Clean the URL
    String cleanUrl = url.trim();
    
    // Check if it's a valid URL
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    try {
      final Uri uri = Uri.parse(cleanUrl);
      
      // Check if can launch
      final bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Try with web view fallback
        final bool canLaunchFallback = await canLaunchUrl(Uri.parse(cleanUrl));
        if (canLaunchFallback) {
          await launchUrl(
            Uri.parse(cleanUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Cannot launch URL');
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '❌ Cannot open link',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'URL: $cleanUrl',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  'Please install a browser or check the URL',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.error),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.error.withOpacity(0.95),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getDifficultyColor(String difficulty, ColorScheme colors) {
    final value = difficulty.toLowerCase();
    if (value.contains('easy')) return colors.secondary;
    if (value.contains('medium')) return colors.primary;
    if (value.contains('hard')) return colors.error;
    return colors.onSurfaceVariant;
  }

  StatusInfo _getStatusInfo(String status, ColorScheme colors) {
    final value = status.toLowerCase();
    if (value.contains('accepted') || value.contains('pass') || value.contains('success')) {
      return StatusInfo(
        label: 'Accepted ✅',
        description: 'Your solution passed all test cases',
        color: colors.secondary,
        icon: Icons.check_circle_rounded,
      );
    }
    if (value.contains('wrong') || value.contains('error') || value.contains('fail')) {
      return StatusInfo(
        label: 'Wrong Answer ❌',
        description: 'Your solution did not pass all test cases',
        color: colors.error,
        icon: Icons.close_rounded,
      );
    }
    if (value.contains('time') || value.contains('limit') || value.contains('tle')) {
      return StatusInfo(
        label: 'Time Limit Exceeded ⏰',
        description: 'Your solution took too long to execute',
        color: colors.primary,
        icon: Icons.timer_outlined,
      );
    }
    return StatusInfo(
      label: 'Pending ⏳',
      description: 'Your submission is being evaluated',
      color: colors.tertiary,
      icon: Icons.hourglass_empty_rounded,
    );
  }
}

class StatusInfo {
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  StatusInfo({
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}