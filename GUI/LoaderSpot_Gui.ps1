
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console

function Show-Search_psf {

    [void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
    [void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

    try {
        [ProgressBarOverlay] | Out-Null
    }
    catch {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $Assemblies = 'System.Windows.Forms', 'System.Drawing', 'System.Drawing.Primitives', 'System.ComponentModel.Primitives', 'System.Drawing.Common', 'System.Runtime'
        }
        else {
            $Assemblies = 'System.Windows.Forms', 'System.Drawing'  

        }
        Add-Type -ReferencedAssemblies $Assemblies -TypeDefinition @"
		using System;
		using System.Windows.Forms;
		using System.Drawing;
        namespace SAPIENTypes
        {
		    public class ProgressBarOverlay : System.Windows.Forms.ProgressBar
	        {
                public ProgressBarOverlay() : base() { SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint, true); }
	            protected override void WndProc(ref Message m)
	            { 
	                base.WndProc(ref m);
	                if (m.Msg == 0x000F)// WM_PAINT
	                {
	                    if (Style != System.Windows.Forms.ProgressBarStyle.Marquee || !string.IsNullOrEmpty(this.Text))
                        {
                            using (Graphics g = this.CreateGraphics())
                            {
                                using (StringFormat stringFormat = new StringFormat(StringFormatFlags.NoWrap))
                                {
                                    stringFormat.Alignment = StringAlignment.Center;
                                    stringFormat.LineAlignment = StringAlignment.Center;
                                    if (!string.IsNullOrEmpty(this.Text))
                                        g.DrawString(this.Text, this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
                                    else
                                    {
                                        int percent = (int)(((double)Value / (double)Maximum) * 100);
                                        g.DrawString(percent.ToString() + "%", this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
                                    }
                                }
                            }
                        }
	                }
	            }
              
                public string TextOverlay
                {
                    get
                    {
                        return base.Text;
                    }
                    set
                    {
                        base.Text = value;
                        Invalidate();
                    }
                }
	        }
        }
"@ -IgnoreWarnings | Out-Null
    }

    [System.Windows.Forms.Application]::EnableVisualStyles()
    $formFindingASpotifyClien = New-Object 'System.Windows.Forms.Form'
    $progressbar1 = New-Object 'SAPIENTypes.ProgressBarOverlay'
    $textbox1 = New-Object 'System.Windows.Forms.TextBox'
    $linklabelFoundLinks = New-Object 'System.Windows.Forms.LinkLabel'
    $groupbox2 = New-Object 'System.Windows.Forms.GroupBox'
    $labelEnterSpotifyVersion = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox1 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $labelForExample1182758g8b = New-Object 'System.Windows.Forms.Label'
    $groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
    $labelMaximumNumberFromFou = New-Object 'System.Windows.Forms.Label'
    $labelEnterSearchRange = New-Object 'System.Windows.Forms.Label'
    $labelTo = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox2 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $labelFrom = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox3 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $buttonStartSearch = New-Object 'System.Windows.Forms.Button'
    $buttonExit = New-Object 'System.Windows.Forms.Button'
    $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

    function Update-ListBox {
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            [System.Windows.Forms.ListBox]
            $ListBox,
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            $Items,
            [Parameter(Mandatory = $false)]
            [string]
            $DisplayMember,
            [Parameter(Mandatory = $false)]
            [string]$ValueMember,
            [switch]
            $Append
        )
		
        if (-not $Append) {
            $listBox.Items.Clear()
        }
		
        if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection]) {
            $listBox.Items.AddRange($Items)
        }
        elseif ($Items -is [Array]) {
            $listBox.BeginUpdate()
            foreach ($obj in $Items) {
                $listBox.Items.Add($obj)
            }
            $listBox.EndUpdate()
        }
        else {
            $listBox.Items.Add($Items)
        }
		
        if ($DisplayMember) {
            $listBox.DisplayMember = $DisplayMember
        }
        if ($ValueMember) {
            $ListBox.ValueMember = $ValueMember
        }
    }
	
	
	
    function Update-ComboBox {	
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            [System.Windows.Forms.ComboBox]
            $ComboBox,
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            $Items,
            [Parameter(Mandatory = $false)]
            [string]$DisplayMember,
            [Parameter(Mandatory = $false)]
            [string]$ValueMember,
            [switch]
            $Append
        )
		
        if (-not $Append) {
            $ComboBox.Items.Clear()
        }
		
        if ($Items -is [Object[]]) {
            $ComboBox.Items.AddRange($Items)
        }
        elseif ($Items -is [System.Collections.IEnumerable]) {
            $ComboBox.BeginUpdate()
            foreach ($obj in $Items) {
                $ComboBox.Items.Add($obj)
            }
            $ComboBox.EndUpdate()
        }
        else {
            $ComboBox.Items.Add($Items)
        }
		
        if ($DisplayMember) {
            $ComboBox.DisplayMember = $DisplayMember
        }
		
        if ($ValueMember) {
            $ComboBox.ValueMember = $ValueMember
        }
    }
	
	
    $buttonStartSearch_Click = {
        # Search button logic
		
        if ($maskedtextbox2.Text -notmatch "\D" -and $maskedtextbox3.Text -notmatch "\D") {
			
            $ErrorActionPreference = 'SilentlyContinue'
            $version_spoti = $maskedtextbox1.Text
            $numbers = [int]$maskedtextbox2.Text
            $before_enter = [int]$maskedtextbox3.Text
			
            if ($before_enter -gt $numbers) {
				
                if ($version_spoti -match '^\d.\d.\d{1,2}.\d{1,5}.[a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]$') {
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    $textbox1.AppendText("Search...")
					
                    $numbers_bar = 0
                    $progressbar1.Minimum = 0
                    $progressbar1.Maximum = $before_enter - $numbers
					
                    While ($numbers -le $before_enter) {
						
                        $progressbar1.Value = $numbers_bar
                        $numbers_bar++
						
						
                        $_URL = "https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-$version_spoti-$numbers.exe"
						
						
                        try {
                            $request = [System.Net.WebRequest]::Create($_URL)
                            $response = $request.getResponse()
							
                            if ($response.StatusCode -eq "200") {
                                $response.ResponseUri.OriginalString
                                $find_url += [System.Environment]::NewLine + $response.ResponseUri.OriginalString
                                $response.Close()
                            }
							
                        }
                        catch
                        { }
                        $numbers++
                    }
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    $textbox1.AppendText([System.Environment]::NewLine + "Search completed")
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    if ($find_url) {
                        $textbox1.AppendText([System.Environment]::NewLine + "Found links:")
                        $textbox1.AppendText([System.Environment]::NewLine + $find_url)
                        $textbox1.AppendText([System.Environment]::NewLine + "`n")
                    }
                    if (!($find_url)) {
                        $textbox1.AppendText([System.Environment]::NewLine + "The search returned no results, try increasing the range.")
                        $textbox1.AppendText([System.Environment]::NewLine + "`n")
                    }
                }
                else {
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    $textbox1.AppendText("Unsuccessfully")
                    $textbox1.AppendText([System.Environment]::NewLine + "Spotify version entered incorrectly")
                    $textbox1.AppendText([System.Environment]::NewLine + "`n")
                }
            }
            else {
                $textbox1.AppendText([System.Environment]::NewLine + "")
                $textbox1.AppendText("Unsuccessfully")
                $textbox1.AppendText([System.Environment]::NewLine + "Search range entered incorrectly")
                $textbox1.AppendText([System.Environment]::NewLine + "The start range cannot be greater than the end range.")
                $textbox1.AppendText([System.Environment]::NewLine + "`n")
            }
        }
        else {
            $textbox1.AppendText([System.Environment]::NewLine + "")
            $textbox1.AppendText("Unsuccessfully")
            $textbox1.AppendText([System.Environment]::NewLine + "Search range entered incorrectly")
            $textbox1.AppendText([System.Environment]::NewLine + "Enter only numbers")
            $textbox1.AppendText([System.Environment]::NewLine + "`n")
        }
    }
	
    $buttonExit_Click = {
        # Exit button logic
        $formFindingASpotifyClien.hide()
    }
    $linklabelFoundLinks_LinkClicked = [System.Windows.Forms.LinkLabelLinkClickedEventHandler] {
        #Event Argument: $_ = [System.Windows.Forms.LinkLabelLinkClickedEventArgs]
        Start-Process "https://cutt.ly/8EH6NuH"
    }
	
    $Form_StateCorrection_Load =
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $formFindingASpotifyClien.WindowState = $InitialFormWindowState
    }
	
    $Form_Cleanup_FormClosed =
    {
        #Remove all event handlers from the controls
        try {
            $linklabelFoundLinks.remove_LinkClicked($linklabelFoundLinks_LinkClicked)
            $buttonStartSearch.remove_Click($buttonStartSearch_Click)
            $buttonExit.remove_Click($buttonExit_Click)
            $formFindingASpotifyClien.remove_Load($Form_StateCorrection_Load)
            $formFindingASpotifyClien.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
    }
	
    $formFindingASpotifyClien.SuspendLayout()
    $groupbox2.SuspendLayout()
    $groupbox1.SuspendLayout()
    #
    # formFindingASpotifyClien
    #
    $formFindingASpotifyClien.Controls.Add($progressbar1)
    $formFindingASpotifyClien.Controls.Add($textbox1)
    $formFindingASpotifyClien.Controls.Add($linklabelFoundLinks)
    $formFindingASpotifyClien.Controls.Add($groupbox2)
    $formFindingASpotifyClien.Controls.Add($groupbox1)
    $formFindingASpotifyClien.Controls.Add($buttonStartSearch)
    $formFindingASpotifyClien.Controls.Add($buttonExit)
    $formFindingASpotifyClien.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
    $formFindingASpotifyClien.AutoScaleMode = 'Font'
    $formFindingASpotifyClien.AutoSizeMode = 'GrowAndShrink'
    $formFindingASpotifyClien.ClientSize = New-Object System.Drawing.Size(444, 370)
    $formFindingASpotifyClien.MaximizeBox = $False
    $formFindingASpotifyClien.Name = 'formFindingASpotifyClien'
    $formFindingASpotifyClien.ShowIcon = $False
    $formFindingASpotifyClien.SizeGripStyle = 'Hide'
    $formFindingASpotifyClien.StartPosition = 'CenterScreen'
    $formFindingASpotifyClien.Text = 'Finding a Spotify Client'
    #
    # progressbar1
    #
    $progressbar1.Location = New-Object System.Drawing.Point(12, 307)
    $progressbar1.Name = 'progressbar1'
    $progressbar1.Size = New-Object System.Drawing.Size(420, 23)
    $progressbar1.TabIndex = 18
    #
    # textbox1
    #
    $textbox1.Font = [System.Drawing.Font]::new('Tahoma', '6.75')
    $textbox1.Location = New-Object System.Drawing.Point(13, 149)
    $textbox1.Multiline = $True
    $textbox1.Name = 'textbox1'
    $textbox1.ReadOnly = $True
    $textbox1.ScrollBars = 'Both'
    $textbox1.Size = New-Object System.Drawing.Size(419, 151)
    $textbox1.TabIndex = 17
    #
    # linklabelFoundLinks
    #
    $linklabelFoundLinks.LinkColor = [System.Drawing.SystemColors]::HotTrack 
    $linklabelFoundLinks.Location = New-Object System.Drawing.Point(12, 341)
    $linklabelFoundLinks.Name = 'linklabelFoundLinks'
    $linklabelFoundLinks.Size = New-Object System.Drawing.Size(62, 17)
    $linklabelFoundLinks.TabIndex = 16
    $linklabelFoundLinks.TabStop = $True
    $linklabelFoundLinks.Text = 'Found links'
    $linklabelFoundLinks.VisitedLinkColor = [System.Drawing.Color]::SlateBlue 
    $linklabelFoundLinks.add_LinkClicked($linklabelFoundLinks_LinkClicked)
    #
    # groupbox2
    #
    $groupbox2.Controls.Add($labelEnterSpotifyVersion)
    $groupbox2.Controls.Add($maskedtextbox1)
    $groupbox2.Controls.Add($labelForExample1182758g8b)
    $groupbox2.Location = New-Object System.Drawing.Point(228, 20)
    $groupbox2.Name = 'groupbox2'
    $groupbox2.Size = New-Object System.Drawing.Size(204, 122)
    $groupbox2.TabIndex = 13
    $groupbox2.TabStop = $False
    #
    # labelEnterSpotifyVersion
    #
    $labelEnterSpotifyVersion.AutoSize = $True
    $labelEnterSpotifyVersion.Font = [System.Drawing.Font]::new('Tahoma', '9', [System.Drawing.FontStyle]'Bold')
    $labelEnterSpotifyVersion.Location = New-Object System.Drawing.Point(30, 16)
    $labelEnterSpotifyVersion.Name = 'labelEnterSpotifyVersion'
    $labelEnterSpotifyVersion.Size = New-Object System.Drawing.Size(138, 14)
    $labelEnterSpotifyVersion.TabIndex = 3
    $labelEnterSpotifyVersion.Text = 'Enter Spotify Version'
    #
    # maskedtextbox1
    #
    $maskedtextbox1.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $maskedtextbox1.Location = New-Object System.Drawing.Point(24, 87)
    $maskedtextbox1.Name = 'maskedtextbox1'
    $maskedtextbox1.Size = New-Object System.Drawing.Size(158, 21)
    $maskedtextbox1.TabIndex = 2
    $maskedtextbox1.TextAlign = 'Center'
    #
    # labelForExample1182758g8b
    #
    $labelForExample1182758g8b.AccessibleDescription = ''
    $labelForExample1182758g8b.AccessibleName = ''
    $labelForExample1182758g8b.AutoSize = $True
    $labelForExample1182758g8b.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $labelForExample1182758g8b.Location = New-Object System.Drawing.Point(40, 48)
    $labelForExample1182758g8b.Name = 'labelForExample1182758g8b'
    $labelForExample1182758g8b.Size = New-Object System.Drawing.Size(118, 26)
    $labelForExample1182758g8b.TabIndex = 4
    $labelForExample1182758g8b.Text = 'For example:
1.1.82.758.g8b7b66c7'
    #
    # groupbox1
    #
    $groupbox1.Controls.Add($labelMaximumNumberFromFou)
    $groupbox1.Controls.Add($labelEnterSearchRange)
    $groupbox1.Controls.Add($labelTo)
    $groupbox1.Controls.Add($maskedtextbox2)
    $groupbox1.Controls.Add($labelFrom)
    $groupbox1.Controls.Add($maskedtextbox3)
    $groupbox1.Location = New-Object System.Drawing.Point(12, 20)
    $groupbox1.Name = 'groupbox1'
    $groupbox1.Size = New-Object System.Drawing.Size(204, 122)
    $groupbox1.TabIndex = 12
    $groupbox1.TabStop = $False
    #
    # labelMaximumNumberFromFou
    #
    $labelMaximumNumberFromFou.AutoSize = $True
    $labelMaximumNumberFromFou.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $labelMaximumNumberFromFou.Location = New-Object System.Drawing.Point(40, 48)
    $labelMaximumNumberFromFou.Name = 'labelMaximumNumberFromFou'
    $labelMaximumNumberFromFou.Size = New-Object System.Drawing.Size(118, 26)
    $labelMaximumNumberFromFou.TabIndex = 14
    $labelMaximumNumberFromFou.Text = 'Maximum number from 
found links was 490.'
    #
    # labelEnterSearchRange
    #
    $labelEnterSearchRange.AutoSize = $True
    $labelEnterSearchRange.Font = [System.Drawing.Font]::new('Tahoma', '9', [System.Drawing.FontStyle]'Bold')
    $labelEnterSearchRange.Location = New-Object System.Drawing.Point(40, 16)
    $labelEnterSearchRange.Name = 'labelEnterSearchRange'
    $labelEnterSearchRange.Size = New-Object System.Drawing.Size(122, 14)
    $labelEnterSearchRange.TabIndex = 6
    $labelEnterSearchRange.Text = 'Enter search range'
    #
    # labelTo
    #
    $labelTo.AutoSize = $True
    $labelTo.Font = [System.Drawing.Font]::new('Lucida Console', '8.25')
    $labelTo.Location = New-Object System.Drawing.Point(103, 92)
    $labelTo.Name = 'labelTo'
    $labelTo.Size = New-Object System.Drawing.Size(19, 11)
    $labelTo.TabIndex = 11
    $labelTo.Text = 'to'
    #
    # maskedtextbox2
    #
    $maskedtextbox2.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $maskedtextbox2.Location = New-Object System.Drawing.Point(45, 87)
    $maskedtextbox2.Name = 'maskedtextbox2'
    $maskedtextbox2.Size = New-Object System.Drawing.Size(50, 21)
    $maskedtextbox2.TabIndex = 5
    $maskedtextbox2.Text = '0'
    $maskedtextbox2.TextAlign = 'Center'
    #
    # labelFrom
    #
    $labelFrom.AutoSize = $True
    $labelFrom.Font = [System.Drawing.Font]::new('Lucida Console', '8.25')
    $labelFrom.Location = New-Object System.Drawing.Point(6, 92)
    $labelFrom.Name = 'labelFrom'
    $labelFrom.Size = New-Object System.Drawing.Size(33, 11)
    $labelFrom.TabIndex = 10
    $labelFrom.Text = 'From'
    #
    # maskedtextbox3
    #
    $maskedtextbox3.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $maskedtextbox3.Location = New-Object System.Drawing.Point(128, 87)
    $maskedtextbox3.Name = 'maskedtextbox3'
    $maskedtextbox3.Size = New-Object System.Drawing.Size(50, 21)
    $maskedtextbox3.TabIndex = 8
    $maskedtextbox3.Text = '100'
    $maskedtextbox3.TextAlign = 'Center'
    #
    # buttonStartSearch
    #
    $buttonStartSearch.Location = New-Object System.Drawing.Point(333, 336)
    $buttonStartSearch.Name = 'buttonStartSearch'
    $buttonStartSearch.Size = New-Object System.Drawing.Size(99, 23)
    $buttonStartSearch.TabIndex = 1
    $buttonStartSearch.Text = 'Start Search'
    $buttonStartSearch.UseVisualStyleBackColor = $True
    $buttonStartSearch.add_Click($buttonStartSearch_Click)
    #
    # buttonExit
    #
    $buttonExit.Location = New-Object System.Drawing.Point(252, 336)
    $buttonExit.Name = 'buttonExit'
    $buttonExit.Size = New-Object System.Drawing.Size(75, 23)
    $buttonExit.TabIndex = 0
    $buttonExit.TabStop = $False
    $buttonExit.Text = 'Exit'
    $buttonExit.UseVisualStyleBackColor = $True
    $buttonExit.add_Click($buttonExit_Click)
    $groupbox1.ResumeLayout()
    $groupbox2.ResumeLayout()
    $formFindingASpotifyClien.ResumeLayout()

    #Save the initial state of the form
    $InitialFormWindowState = $formFindingASpotifyClien.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $formFindingASpotifyClien.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $formFindingASpotifyClien.add_FormClosed($Form_Cleanup_FormClosed)
    #Show the Form
    return $formFindingASpotifyClien.ShowDialog()

} #End Function

#Call the form
Show-Search_psf | Out-Null