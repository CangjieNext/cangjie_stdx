#!/usr/bin/env python3
"""
Timer Data Visualization Script

This script reads timeSave.csv file and generates:
1. Line chart: Shows time consumption trends for different info across multiple executions
2. Pie chart: Shows time distribution for different info in a single execution
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import argparse
import os
import sys
import json

def load_data(csv_file):
    """
    Load data from CSV file
    
    Args:
        csv_file: Path to the CSV file
        
    Returns:
        DataFrame with the loaded data
    """
    try:
        df = pd.read_csv(csv_file)
        print(f"Successfully loaded {len(df)} records from {csv_file}")
        print("\nData preview:")
        print(df.head())
        return df
    except FileNotFoundError:
        print(f"Error: File '{csv_file}' not found.")
        sys.exit(1)
    except pd.errors.EmptyDataError:
        print(f"Error: File '{csv_file}' is empty.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        sys.exit(1)

def load_config(config_file):
    """
    Load configuration from JSON file
    
    Args:
        config_file: Path to the config file
        
    Returns:
        Dictionary with configuration
    """
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        print(f"Successfully loaded config from {config_file}")
        return config
    except FileNotFoundError:
        print(f"Warning: Config file '{config_file}' not found. Using default settings.")
        return {'line_chart': {'show_all': True}}
    except json.JSONDecodeError as e:
        print(f"Warning: Invalid JSON in config file '{config_file}': {e}")
        return {'line_chart': {'show_all': True}}
    except Exception as e:
        print(f"Warning: Error loading config file '{config_file}': {e}")
        return {'line_chart': {'show_all': True}}

def convert_timestamp(timestamp):
    """
    Convert nanosecond timestamp to datetime
    
    Args:
        timestamp: Nanosecond timestamp
        
    Returns:
        datetime object
    """
    try:
        return datetime.fromtimestamp(timestamp / 1e9)
    except:
        return datetime.now()

def group_by_execution(df):
    """
    Group data by execution batch based on record pattern
    
    Args:
        df: DataFrame with timestamp column
        
    Returns:
        DataFrame with execution_id column added
    """
    df = df.copy()
    df['datetime'] = df['timestamp'].apply(convert_timestamp)
    
    execution_id = 0
    execution_ids = []
    
    for idx, row in df.iterrows():
        info = row['info']
        
        if idx == 0:
            execution_ids.append(execution_id)
        else:
            prev_info = df.iloc[idx-1]['info']
            
            if 'Stage 1.1' in info and 'Total Analye' in prev_info:
                execution_id += 1
            elif 'Stage 1.1' in info and idx > 10:
                execution_id += 1
            
            execution_ids.append(execution_id)
    
    df['execution_id'] = execution_ids
    return df

def generate_line_chart(df, output_file='timer_line_chart.png', execution_id=None, config=None):
    """
    Generate line chart showing time consumption trends
    
    Args:
        df: DataFrame with timer data
        output_file: Output file path for the chart
        execution_id: Specific execution ID to be analyzed (None for all)
        config: Configuration dictionary
    """
    df = group_by_execution(df)
    
    if execution_id is not None:
        df = df[df['execution_id'] == execution_id]
        if df.empty:
            print(f"Error: No data found for execution_id={execution_id}")
            return
    
    # Filter infos based on config
    show_all = True
    show_infos = None
    
    if config and 'line_chart' in config:
        line_chart_config = config['line_chart']
        show_all = line_chart_config.get('show_all', True)
        show_infos = line_chart_config.get('show_infos', None)
    
    if not show_all and show_infos:
        df = df[df['info'].isin(show_infos)]
        if df.empty:
            print(f"Error: No data found for specified infos: {show_infos}")
            return
        print(f"Filtering to show only: {show_infos}")
    
    plt.figure(figsize=(14, 8))
    
    unique_infos = df['info'].unique()
    colors = plt.cm.tab20(range(len(unique_infos)))
    
    for idx, info in enumerate(unique_infos):
        info_data = df[df['info'] == info]
        execution_counts = range(len(info_data))
        plt.plot(execution_counts, info_data['time'], 
                marker='o', linewidth=2, markersize=6,
                label=info, color=colors[idx])
    
    plt.xlabel('Execution Count', fontsize=12, fontweight='bold')
    plt.ylabel('Time (ms)', fontsize=12, fontweight='bold')
    title = 'Timer Data - Time Consumption Trends'
    if execution_id is not None:
        title += f' (Execution {execution_id})'
    plt.title(title, fontsize=14, fontweight='bold', pad=20)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Line chart saved to: {output_file}")
    plt.close()

def generate_pie_chart(df, output_file='timer_pie_chart.png', execution_id=None):
    """
    Generate pie charts showing time distribution for a single execution
    
    Args:
        df: DataFrame with timer data
        output_file: Output file path for the chart
        execution_id: Specific execution ID to be analyzed (None for latest)
)
    """
    df = group_by_execution(df)
    
    if execution_id is None:
        execution_id = df['execution_id'].max()
    
    execution_data = df[df['execution_id'] == execution_id]
    
    if execution_data.empty:
        print(f"Error: No data found for execution_id={execution_id}")
        return
    
    grouped = execution_data.groupby('info')['time'].sum()
    
    stage1_1 = grouped.get('Stage 1.1: Serial GreenTree', 0)
    stage1_2 = grouped.get('Stage 1.2: CFFI memory copy data', 0)
    stage2_1 = grouped.get('Stage 2.1: Deserial GreenTree', 0)
    stage2_2 = grouped.get('Stage 2.2: Parse', 0)
    stage2_3 = grouped.get('Stage 2.3: TypeCollector', 0)
    stage2_4 = grouped.get('Stage 2.4: Import', 0)
    stage2_5 = grouped.get('Stage 2.5: Sema', 0)
    stage2_6 = grouped.get('Stage 2.6: Serial semantic result', 0)
    stage2_cffi = grouped.get('Stage 2: CFFI', 0)
    stage2_total_native = grouped.get('Stage 2: Total native', 0)
    stage3_1 = grouped.get('Stage 3.1: Deserial semantic result', 0)
    stage3_2 = grouped.get('Stage 3.2: Deserial Result of TypeMap', 0)
    stage4 = grouped.get('Stage 4: Analye impl in cangjie', 0)
    
    stage1_total = stage1_1 + stage1_2
    stage2_total = stage2_cffi
    stage3_total = stage3_1 + stage3_2
    stage4_total = stage4
    stage2_7 = stage2_cffi - stage2_total_native
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(20, 10))
    
    main_stages = {
        'Stage 1': stage1_total,
        'Stage 2': stage2_total,
        'Stage 3': stage3_total,
        'Stage 4': stage4_total
    }
    
    colors1 = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']
    wedges1, texts1, autotexts1 = ax1.pie(
        main_stages.values(),
        labels=None,
        autopct=lambda p: f'{p:.1f}%',
        colors=colors1,
        startangle=90,
        pctdistance=0.85,
        textprops={'fontsize': 12, 'fontweight': 'bold'}
    )
    
    for autotext in autotexts1:
        autotext.set_color('white')
        autotext.set_fontweight('bold')
    
    legend_labels1 = [f'{label}: {value:.2f} ms ({value/sum(main_stages.values())*100:.1f}%)' 
                      for label, value in main_stages.items()]
    
    ax1.legend(wedges1, legend_labels1,
              title='Main Stages',
              loc='center left',
              bbox_to_anchor=(1, 0, 0.5, 1),
              fontsize=11)
    
    ax1.set_title(f'Main Stage Distribution (Execution {execution_id})',
                  fontsize=14, fontweight='bold', pad=20)
    
    stage2_sub = {
        'Stage 2.1: Deserial GreenTree': stage2_1,
        'Stage 2.2: Parse': stage2_2,
        'Stage 2.3: TypeCollector': stage2_3,
        'Stage 2.4: Import': stage2_4,
        'Stage 2.5: Sema': stage2_5,
        'Stage 2.6: Serial semantic result': stage2_6,
        'Stage 2.7: ffi': stage2_7
    }
    
    stage2_sub = {k: v for k, v in stage2_sub.items() if v > 0}
    
    colors2 = plt.cm.Set3(range(len(stage2_sub)))
    wedges2, texts2, autotexts2 = ax2.pie(
        stage2_sub.values(),
        labels=None,
        autopct=lambda p: f'{p:.1f}%' if p > 5 else '',
        colors=colors2,
        startangle=90,
        pctdistance=0.85,
        textprops={'fontsize': 10, 'fontweight': 'bold'}
    )
    
    for autotext in autotexts2:
        if autotext.get_text():
            autotext.set_color('white')
            autotext.set_fontweight('bold')
    
    legend_labels2 = [f'{label}: {value:.2f} ms ({value/sum(stage2_sub.values())*100:.1f}%)' 
                      for label, value in stage2_sub.items()]
    
    ax2.legend(wedges2, legend_labels2,
              title='Stage 2 Sub-stages',
              loc='center left',
              bbox_to_anchor=(1, 0, 0.5, 1),
              fontsize=10)
    
    ax2.set_title(f'Stage 2 Sub-stage Distribution (Execution {execution_id})',
                  fontsize=14, fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Pie charts saved to: {output_file}")
    plt.close()

def generate_execution_summary(df):
    """
    Generate summary statistics for each execution
    
    Args:
        df: DataFrame with timer data
    """
    df = group_by_execution(df)
    
    print("\n" + "="*60)
    print("EXECUTION SUMMARY")
    print("="*60)
    
    for exec_id in sorted(df['execution_id'].unique()):
        exec_data = df[df['execution_id'] == exec_id]
        start_time = exec_data['datetime'].min()
        total_time = exec_data['time'].sum()
        
        print(f"\nExecution {exec_id}:")
        print(f"  Start Time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"  Total Time: {total_time:.2f} ms")
        print(f"  Number of Records: {len(exec_data)}")
        print(f"  Unique Info Types: {exec_data['info'].nunique()}")
        
        print("  Top 5 Time Consumers:")
        top_consumers = exec_data.groupby('info')['time'].sum().sort_values(ascending=False).head(5)
        for info, time in top_consumers.items():
            percentage = (time / total_time) * 100
            print(f"    - {info}: {time:.2f} ms ({percentage:.1f}%)")

def main():
    parser = argparse.ArgumentParser(description='Visualize timer data from timeSave.csv')
    parser.add_argument('--csv', default='./timeSave.csv', 
                       help='Path to CSV file (default: ./timeSave.csv)')
    parser.add_argument('--config', default='./config.json',
                       help='Path to config file (default: ./config.json)')
    parser.add_argument('--execution', type=int, default=None,
                       help='Specific execution ID to analyze (default: all for line chart, latest for pie chart)')
    parser.add_argument('--output-line', default='timer_line_chart.png',
                       help='Output file for line chart (default: timer_line_chart.png)')
    parser.add_argument('--output-pie', default='timer_pie_chart.png',
                       help='Output file for pie chart (default: timer_pie_chart.png)')
    parser.add_argument('--no-line', action='store_true',
                       help='Skip generating line chart')
    parser.add_argument('--no-pie', action='store_true',
                       help='Skip generating pie chart')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.csv):
        print(f"Error: CSV file '{args.csv}' not found.")
        print("Please ensure the timerSave.csv file exists and contains data.")
        sys.exit(1)
    
    df = load_data(args.csv)
    
    if df.empty:
        print("Error: No data found in CSV file.")
        sys.exit(1)
    
    config = load_config(args.config)
    
    generate_execution_summary(df)
    
    if not args.no_line:
        generate_line_chart(df, args.output_line, args.execution, config)
    
    if not args.no_pie:
        generate_pie_chart(df, args.output_pie, args.execution)
    
    print("\n" + "="*60)
    print("Visualization complete!")
    print("="*60)

if __name__ == '__main__':
    main()
