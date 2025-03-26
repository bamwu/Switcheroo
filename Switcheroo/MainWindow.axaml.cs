using System;
using System.Diagnostics;
using System.Net;
using System.IO;
using System.Runtime.InteropServices;
using Avalonia.Controls;

namespace Switcheroo;

public partial class MainWindow : Window
{
    public static string ARCH()
    {
        Architecture arch = RuntimeInformation.ProcessArchitecture;

        switch (arch)
        {
            case Architecture.X86:   { return "INTEL/32"; }
            case Architecture.X64:   { return "INTEL/64"; }
            case Architecture.Arm64: { return   "ARM/64"; }
        }

        return null;
    }
    
    public MainWindow()
    {
        InitializeComponent();
        
        ArchitectureLabel.Content = ARCH();
        try
        {
            MessageLabel.Content = File.ReadAllText(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "switcheroo-message.txt"));
        }
        catch (Exception exception)
        {
            MessageLabel.Content = exception.GetType().Name;
        }
    }
}

