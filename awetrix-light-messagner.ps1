# Create main Form for the App
Add-Type -assembly System.Windows.Forms
$FormMain = New-Object System.Windows.Forms.Form
$FormMain.Text ='Message4Schatz'
$FormMain.Width = 400
$FormMain.Height = 400
$FormMain.AutoScale = $true

$FormMain.AutoScaleMode = "Font"
$ASsize = New-Object System.Drawing.SizeF(7,15)
$FormMain.AutoScaleDimensions = $ASsize

# Default APP Config|Parameters
$RainbowColorDefault = $true
if($RainbowColorDefault)
{
    $ComboBoxColorChooserEnabler = $false
    $ComboBoxColorChooserVisible = $false
    $CheckboxRainbowChecked = $true 
}
else
{
    $ComboBoxColorChooserEnabler = $true
    $ComboBoxColorChooserVisible = $true
    $CheckboxRainbowChecked = $false
}
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$colors = Import-Csv $scriptPath\Colors.csv -Delimiter ";"

$IP = # Insert IP 
$URIAdressPOST = "http://$IP/api/notify"
$URIAdressGET  = "http://$IP/api/stats"

$GetStats = Invoke-WebRequest -Method GET -URI $URIAdressGET 

#$evt = Register-ObjectEvent

# Create Label to display "Message" as text
$LabelMessage = New-Object System.Windows.Forms.Label
$LabelMessage.Text = "Message:"
$LabelMessage.Location  = New-Object System.Drawing.Point(10,10)
$LabelMessage.AutoSize = $true
$FormMain.Controls.Add($LabelMessage)

# Create TextBox to input message text
$TextBoxMessage = New-Object System.Windows.Forms.TextBox
$TextBoxMessage.Width = 280
$TextBoxMessage.Location  = New-Object System.Drawing.Point(110,10)
$FormMain.Controls.Add($TextBoxMessage)

$LabelLastMessage = New-Object System.Windows.Forms.Label
$LabelLastMessage.Text = "Last Messages:"
$LabelLastMessage.Location  = New-Object System.Drawing.Point(10,80)
$LabelLastMessage.AutoSize = $true
$FormMain.Controls.Add($LabelLastMessage)

# create output label / textbox
$LabelOutBox = New-Object System.Windows.Forms.Label
$LabelOutBox.Text = ""
$LabelOutBox.Location  = New-Object System.Drawing.Point(110,80)
$LabelOutBox.AutoSize = $true
$FormMain.Controls.Add($LabelOutBox)

# Create Button to send message
$ButtonSend = New-Object System.Windows.Forms.Button
$ButtonSendPosition = $FormMain.Width*0.98
#$ButtonSend.Location = New-Object System.Drawing.Size($ButtonSendPosition,10)
$ButtonSend.Size = New-Object System.Drawing.Size(120,23)
$ButtonSend.Text = "send Message"
$ButtonSend.Anchor = 'Right'
#$ButtonSend.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$FormMain.AcceptButton = $ButtonSend
$FormMain.Controls.Add($ButtonSend)


# Create Check box if Rainbow Color are used
$CheckboxRainbow = new-object System.Windows.Forms.checkbox
$CheckboxRainbow.Location = new-object System.Drawing.Size(530,10)
$CheckboxRainbow.Size = new-object System.Drawing.Size(100,23)
$CheckboxRainbow.Text = "Rainbow Color"
$CheckboxRainbow.Checked = $CheckboxRainbowChecked
$FormMain.Controls.Add($CheckboxRainbow)  

# Create ComboBox to choose color
$ComboBoxColorChooser = New-Object system.Windows.Forms.ComboBox
$ComboBoxColorChooser.text = “”
$ComboBoxColorChooser.width = 120
$ComboBoxColorChooser.autosize = $true

# Add the items in the dropdown list
#@(‘Jack’,’Dave’,’Alex’) | ForEach-Object {[void] $ComboBoxColorChooser.Items.Add($_)}
$colors| ForEach-Object {[void] $ComboBoxColorChooser.Items.Add($_.colorname)}
# Select the default value
#$ComboBoxColorChooser.SelectedIndex = 0
$ComboBoxColorChooser.Enabled = $ComboBoxColorChooserEnabler
$ComboBoxColorChooser.Visible = $ComboBoxColorChooserVisible
$ComboBoxColorChooser.location = New-Object System.Drawing.Point(400,40)
$FormMain.Controls.Add($ComboBoxColorChooser)


#$Task = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($IP)
#$Task.Result.Status

# Functions Area

$CheckboxRainbow.Add_CheckStateChanged(
{
    if ($CheckboxRainbow.Checked)
    {
        $ComboBoxColorChooser.Enabled = $false
        $ComboBoxColorChooser.Visible = $false
    }
    else
    {
        $ComboBoxColorChooser.Enabled = $true
        $ComboBoxColorChooser.Visible = $true
    }
})


$ButtonSend.Add_Click(
    {
        ForEach($color in $colors)
        {
            if ($color.colorname -eq $ComboBoxColorChooser.SelectedItem)
            {$HexColorCode = $color.colorcode}
        }

        $postParam = @{}
        $postParam.text = $TextBoxMessage.Text
        $postParam.rainbow = $CheckboxRainbow.Checked
        $postParam.color = $HexColorCode
        $postParam.sound = "message"
        $postParam.icon = 32844
        $iwrbody = ConvertTo-Json $postParam
        
        Invoke-WebRequest -Method POST -Body $iwrbody -H @{"Content-Type" = "application/json"} -URI $URIAdressPOST 
        
        $datetime = Get-Date
        $LabelOutBox.Text += $datetime.ToString() + " # " + $TextBoxMessage.Text +" # "+$ComboBoxColorChooser.SelectedItem  +"`n"
    }
)

$FormMain.ShowDialog()| Out-Null
$FormMain.Dispose()