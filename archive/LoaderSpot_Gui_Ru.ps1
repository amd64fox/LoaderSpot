
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
    $formПоискКлиентаSpotify = New-Object 'System.Windows.Forms.Form'
    $progressbar1 = New-Object 'SAPIENTypes.ProgressBarOverlay'
    $textbox1 = New-Object 'System.Windows.Forms.TextBox'
    $linklabelНайденныеСсылки = New-Object 'System.Windows.Forms.LinkLabel'
    $groupbox2 = New-Object 'System.Windows.Forms.GroupBox'
    $labelВведитеВерсиюSpotify = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox1 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $labelНапример1182758g8b7b = New-Object 'System.Windows.Forms.Label'
    $groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
    $labelМаксимальныйНомерИзН = New-Object 'System.Windows.Forms.Label'
    $labelВведитеДиапозонПоиск = New-Object 'System.Windows.Forms.Label'
    $labelДо = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox2 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $labelОт = New-Object 'System.Windows.Forms.Label'
    $maskedtextbox3 = New-Object 'System.Windows.Forms.MaskedTextBox'
    $buttonНачатьПоиск = New-Object 'System.Windows.Forms.Button'
    $buttonВыйти = New-Object 'System.Windows.Forms.Button'
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
	
	
    $buttonНачатьПоиск_Click = {
        # Логика кнопки поиск
		
        if ($maskedtextbox2.Text -notmatch "\D" -and $maskedtextbox3.Text -notmatch "\D") {
			
            $ErrorActionPreference = 'SilentlyContinue'
            $version_spoti = $maskedtextbox1.Text
            $numbers = [int]$maskedtextbox2.Text
            $before_enter = [int]$maskedtextbox3.Text
			
            if ($before_enter -gt $numbers) {
				
                if ($version_spoti -match '^\d.\d.\d{1,2}.\d{1,5}.[a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]$') {
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    $textbox1.AppendText("Поиск...")
					
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
                    $textbox1.AppendText([System.Environment]::NewLine + "Поиск завершен")
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    if ($find_url) {
                        $textbox1.AppendText([System.Environment]::NewLine + "Найденные ссылки :")
                        $textbox1.AppendText([System.Environment]::NewLine + $find_url)
                        $textbox1.AppendText([System.Environment]::NewLine + "`n")
                    }
                    if (!($find_url)) {
                        $textbox1.AppendText([System.Environment]::NewLine + "Поиск не дал результатов, попробуйте увеличить диапазон.")
                        $textbox1.AppendText([System.Environment]::NewLine + "`n")
                    }
                }
                else {
                    $textbox1.AppendText([System.Environment]::NewLine + "")
                    $textbox1.AppendText("Неудачно")
                    $textbox1.AppendText([System.Environment]::NewLine + "Не корректно введена версия Spotify")
                    $textbox1.AppendText([System.Environment]::NewLine + "`n")
                }
            }
            else {
                $textbox1.AppendText([System.Environment]::NewLine + "")
                $textbox1.AppendText("Неудачно")
                $textbox1.AppendText([System.Environment]::NewLine + "Не корректно введен диапазон поиска")
                $textbox1.AppendText([System.Environment]::NewLine + "Начальный диапазон не может быть больше конечного диапазона")
                $textbox1.AppendText([System.Environment]::NewLine + "`n")
            }
        }
        else {
            $textbox1.AppendText([System.Environment]::NewLine + "")
            $textbox1.AppendText("Неудачно")
            $textbox1.AppendText([System.Environment]::NewLine + "Не корректно введен диапазон поиска")
            $textbox1.AppendText([System.Environment]::NewLine + "Вводите только цифры")
            $textbox1.AppendText([System.Environment]::NewLine + "`n")
        }
    }
    $buttonВыйти_Click = {
        # Логика кнопки выйти
        $formПоискКлиентаSpotify.hide()
    }
    $linklabelНайденныеСсылки_LinkClicked = [System.Windows.Forms.LinkLabelLinkClickedEventHandler] {
        Start-Process "https://cutt.ly/8EH6NuH"
    }
	
    $Form_StateCorrection_Load =
    {
        $formПоискКлиентаSpotify.WindowState = $InitialFormWindowState
    }
	
    $Form_Cleanup_FormClosed =
    {
        try {
            $linklabelНайденныеСсылки.remove_LinkClicked($linklabelНайденныеСсылки_LinkClicked)
            $buttonНачатьПоиск.remove_Click($buttonНачатьПоиск_Click)
            $buttonВыйти.remove_Click($buttonВыйти_Click)
            $formПоискКлиентаSpotify.remove_Load($Form_StateCorrection_Load)
            $formПоискКлиентаSpotify.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
    }
    $formПоискКлиентаSpotify.SuspendLayout()
    $groupbox1.SuspendLayout()
    $groupbox2.SuspendLayout()
    #
    # formПоискКлиентаSpotify
    #
    $formПоискКлиентаSpotify.Controls.Add($progressbar1)
    $formПоискКлиентаSpotify.Controls.Add($textbox1)
    $formПоискКлиентаSpotify.Controls.Add($linklabelНайденныеСсылки)
    $formПоискКлиентаSpotify.Controls.Add($groupbox2)
    $formПоискКлиентаSpotify.Controls.Add($groupbox1)
    $formПоискКлиентаSpotify.Controls.Add($buttonНачатьПоиск)
    $formПоискКлиентаSpotify.Controls.Add($buttonВыйти)
    $formПоискКлиентаSpotify.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
    $formПоискКлиентаSpotify.AutoScaleMode = 'Font'
    $formПоискКлиентаSpotify.AutoSizeMode = 'GrowAndShrink'
    $formПоискКлиентаSpotify.ClientSize = New-Object System.Drawing.Size(444, 370)
    $formПоискКлиентаSpotify.MaximizeBox = $False
    $formПоискКлиентаSpotify.Name = 'formПоискКлиентаSpotify'
    $formПоискКлиентаSpotify.ShowIcon = $False
    $formПоискКлиентаSpotify.SizeGripStyle = 'Hide'
    $formПоискКлиентаSpotify.StartPosition = 'CenterScreen'
    $formПоискКлиентаSpotify.Text = 'Поиск клиента Spotify'
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
    # linklabelНайденныеСсылки
    #
    $linklabelНайденныеСсылки.LinkColor = [System.Drawing.SystemColors]::HotTrack 
    $linklabelНайденныеСсылки.Location = New-Object System.Drawing.Point(12, 341)
    $linklabelНайденныеСсылки.Name = 'linklabelНайденныеСсылки'
    $linklabelНайденныеСсылки.Size = New-Object System.Drawing.Size(107, 17)
    $linklabelНайденныеСсылки.TabIndex = 16
    $linklabelНайденныеСсылки.TabStop = $True
    $linklabelНайденныеСсылки.Text = 'Найденные ссылки'
    $linklabelНайденныеСсылки.VisitedLinkColor = [System.Drawing.Color]::SlateBlue 
    $linklabelНайденныеСсылки.add_LinkClicked($linklabelНайденныеСсылки_LinkClicked)
    #
    # groupbox2
    #
    $groupbox2.Controls.Add($labelВведитеВерсиюSpotify)
    $groupbox2.Controls.Add($maskedtextbox1)
    $groupbox2.Controls.Add($labelНапример1182758g8b7b)
    $groupbox2.Location = New-Object System.Drawing.Point(228, 20)
    $groupbox2.Name = 'groupbox2'
    $groupbox2.Size = New-Object System.Drawing.Size(204, 122)
    $groupbox2.TabIndex = 13
    $groupbox2.TabStop = $False
    #
    # labelВведитеВерсиюSpotify
    #
    $labelВведитеВерсиюSpotify.AutoSize = $True
    $labelВведитеВерсиюSpotify.Font = [System.Drawing.Font]::new('Tahoma', '9', [System.Drawing.FontStyle]'Bold')
    $labelВведитеВерсиюSpotify.Location = New-Object System.Drawing.Point(30, 16)
    $labelВведитеВерсиюSpotify.Name = 'labelВведитеВерсиюSpotify'
    $labelВведитеВерсиюSpotify.Size = New-Object System.Drawing.Size(158, 14)
    $labelВведитеВерсиюSpotify.TabIndex = 3
    $labelВведитеВерсиюSpotify.Text = 'Введите версию Spotify'
    #
    # maskedtextbox1
    #
    $maskedtextbox1.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $maskedtextbox1.Location = New-Object System.Drawing.Point(30, 87)
    $maskedtextbox1.Name = 'maskedtextbox1'
    $maskedtextbox1.Size = New-Object System.Drawing.Size(158, 21)
    $maskedtextbox1.TabIndex = 2
    $maskedtextbox1.TextAlign = 'Center'
    #
    # labelНапример1182758g8b7b
    #
    $labelНапример1182758g8b7b.AccessibleDescription = ''
    $labelНапример1182758g8b7b.AccessibleName = ''
    $labelНапример1182758g8b7b.AutoSize = $True
    $labelНапример1182758g8b7b.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $labelНапример1182758g8b7b.Location = New-Object System.Drawing.Point(51, 48)
    $labelНапример1182758g8b7b.Name = 'labelНапример1182758g8b7b'
    $labelНапример1182758g8b7b.Size = New-Object System.Drawing.Size(118, 26)
    $labelНапример1182758g8b7b.TabIndex = 4
    $labelНапример1182758g8b7b.Text = 'Например:
1.1.82.758.g8b7b66c7'
    #
    # groupbox1
    #
    $groupbox1.Controls.Add($labelМаксимальныйНомерИзН)
    $groupbox1.Controls.Add($labelВведитеДиапозонПоиск)
    $groupbox1.Controls.Add($labelДо)
    $groupbox1.Controls.Add($maskedtextbox2)
    $groupbox1.Controls.Add($labelОт)
    $groupbox1.Controls.Add($maskedtextbox3)
    $groupbox1.Location = New-Object System.Drawing.Point(12, 20)
    $groupbox1.Name = 'groupbox1'
    $groupbox1.Size = New-Object System.Drawing.Size(204, 122)
    $groupbox1.TabIndex = 12
    $groupbox1.TabStop = $False
    #
    # labelМаксимальныйНомерИзН
    #
    $labelМаксимальныйНомерИзН.AutoSize = $True
    $labelМаксимальныйНомерИзН.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $labelМаксимальныйНомерИзН.Location = New-Object System.Drawing.Point(27, 48)
    $labelМаксимальныйНомерИзН.Name = 'labelМаксимальныйНомерИзН'
    $labelМаксимальныйНомерИзН.Size = New-Object System.Drawing.Size(151, 26)
    $labelМаксимальныйНомерИзН.TabIndex = 14
    $labelМаксимальныйНомерИзН.Text = 'Максимальный номер из 
найденных ссылок был 490.
'
    #
    # labelВведитеДиапозонПоиск
    #
    $labelВведитеДиапозонПоиск.AutoSize = $True
    $labelВведитеДиапозонПоиск.Font = [System.Drawing.Font]::new('Tahoma', '9', [System.Drawing.FontStyle]'Bold')
    $labelВведитеДиапозонПоиск.Location = New-Object System.Drawing.Point(15, 16)
    $labelВведитеДиапозонПоиск.Name = 'labelВведитеДиапозонПоиск'
    $labelВведитеДиапозонПоиск.Size = New-Object System.Drawing.Size(171, 14)
    $labelВведитеДиапозонПоиск.TabIndex = 6
    $labelВведитеДиапозонПоиск.Text = 'Введите диапазон поиска'
    #
    # labelДо
    #
    $labelДо.AutoSize = $True
    $labelДо.Font = [System.Drawing.Font]::new('Lucida Console', '8.25')
    $labelДо.Location = New-Object System.Drawing.Point(103, 92)
    $labelДо.Name = 'labelДо'
    $labelДо.Size = New-Object System.Drawing.Size(19, 11)
    $labelДо.TabIndex = 11
    $labelДо.Text = 'До'
    #
    # maskedtextbox2
    #
    $maskedtextbox2.Font = [System.Drawing.Font]::new('Tahoma', '8.25')
    $maskedtextbox2.Location = New-Object System.Drawing.Point(40, 87)
    $maskedtextbox2.Name = 'maskedtextbox2'
    $maskedtextbox2.Size = New-Object System.Drawing.Size(50, 21)
    $maskedtextbox2.TabIndex = 5
    $maskedtextbox2.Text = '0'
    $maskedtextbox2.TextAlign = 'Center'
    #
    # labelОт
    #
    $labelОт.AutoSize = $True
    $labelОт.Font = [System.Drawing.Font]::new('Lucida Console', '8.25')
    $labelОт.Location = New-Object System.Drawing.Point(15, 92)
    $labelОт.Name = 'labelОт'
    $labelОт.Size = New-Object System.Drawing.Size(19, 11)
    $labelОт.TabIndex = 10
    $labelОт.Text = 'От'
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
    # buttonНачатьПоиск
    #
    $buttonНачатьПоиск.Location = New-Object System.Drawing.Point(333, 336)
    $buttonНачатьПоиск.Name = 'buttonНачатьПоиск'
    $buttonНачатьПоиск.Size = New-Object System.Drawing.Size(99, 23)
    $buttonНачатьПоиск.TabIndex = 1
    $buttonНачатьПоиск.Text = 'Начать поиск'
    $buttonНачатьПоиск.UseVisualStyleBackColor = $True
    $buttonНачатьПоиск.add_Click($buttonНачатьПоиск_Click)
    #
    # buttonВыйти
    #
    $buttonВыйти.Location = New-Object System.Drawing.Point(252, 336)
    $buttonВыйти.Name = 'buttonВыйти'
    $buttonВыйти.Size = New-Object System.Drawing.Size(75, 23)
    $buttonВыйти.TabIndex = 0
    $buttonВыйти.TabStop = $False
    $buttonВыйти.Text = 'Выйти'
    $buttonВыйти.UseVisualStyleBackColor = $True
    $buttonВыйти.add_Click($buttonВыйти_Click)
    $groupbox2.ResumeLayout()
    $groupbox1.ResumeLayout()
    $formПоискКлиентаSpotify.ResumeLayout()

    #Save the initial state of the form
    $InitialFormWindowState = $formПоискКлиентаSpotify.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $formПоискКлиентаSpotify.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $formПоискКлиентаSpotify.add_FormClosed($Form_Cleanup_FormClosed)
    #Show the Form
    return $formПоискКлиентаSpotify.ShowDialog()

}

#Call the form
Show-Search_psf | Out-Null