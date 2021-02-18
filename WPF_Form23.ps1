# Переделать функции
# ***************************
#$ImagePath = $Global:MyInvocation.invocationname
#$ImagePath = $PSScriptRoot

# Переделать функции
# Set-Variable -Name f1v1,f1v2 -Option AllScope
$Global:CorrectAnsver
$Global:CountQuestion = 0
$Global:CorrectCounter = 0
$Global:arrList
$Global:ArrQuestions = @()

Set-Variable -Name RigntVisible, CheckAnsvers -Option AllScope
# $RigntVisible = $false  # 
$CheckAnsvers = $true # взамен $RigntVisible Для показа экрана с подсказкой

function Out-PanelAnsvers {

    $ListRadioButton = $StackPanelradBtn.Children
    $ListRadioButton.Clear()
    #$StackPanelradBtn.Margin="20,10"

    for ($i = 0; $i -lt $Global:arrList.Count; $i++) {

        $ListDockPanel = New-Object System.Windows.Controls.DockPanel
        $ButtonPic = New-Object System.Windows.Controls.Button
        $ButtonPic.Margin = "30,5,5,0"
        #$ButtonPic.BorderThickness = "0"
        #$ButtonPic.Background = "Transparent"
        #$ButtonPic.BorderBrush = "Transparent"
        $ButtonPic.Height = "50"
        $ButtonPic.Width = "50"
        $ButtonPic.IsEnabled = $false
        $ButtonPic.Visibility = "Hidden"

        $ListDockPanel.AddChild($ButtonPic)

        $ListStackPanel = New-Object System.Windows.Controls.StackPanel
        $ListStackPanel.Margin = "20,0,30,0"
        $ListStackPanel.Background = "#0070c0"

            $RadioButton = New-Object System.Windows.Controls.RadioButton
            $RadioButton.Margin="10,20,25,15"
            $RadioButton.FontFamily="Arial" 
            $RadioButton.Foreground="White" 
            $RadioButton.FontSize="16"  
            $RadioButton.FontWeight="Bold"
            $RadioButton.GroupName="Ansvers"
            $RadioButton.VerticalContentAlignment="Center"
            $TextBlock = New-Object System.Windows.Controls.TextBlock
            $RadioButton.Content = $TextBlock
            $RadioButton.Content.Text=$Global:arrList[$i][1]
            $RadioButton.Content.TextWrapping = "Wrap"
        
        #$ListStackPanel.DataContext = $RadioButton
        $ListStackPanel.AddChild($RadioButton)

        #$ListDockPanel.AddChild($RadioButton)
        $ListDockPanel.AddChild($ListStackPanel)
        $ListRadioButton.add($ListDockPanel)
    }
}

function Get-Qusetion {

    # Случайный вопрос 
    $Random = $Global:ArrQuestions | Get-Random

    # Убираем выбранный вопрос из списка массива
    $Global:ArrQuestions = $Global:ArrQuestions | Where-Object { $_ -ne $Random }    
    
    # Получаем список вариантов ответов
    $Record1 = New-Object -com ADODB.Recordset
    $Record2 = New-Object -com ADODB.Recordset
    # Вопрос
    $Record1.Open("Select * From Question Where ID_Que = $Random", $Conn, 3)
    # Варианты ответов
    $Record2.Open("Select * From Ansvers Where ID_Question = $Random", $Conn, 3 )

    # Вывод вопроса
    $txtblQuestion.Text = $Record1.Fields.Item(1).value
    #$CorrectAnsver = 0
    # Добавить проверку на количество выриантов ответов        
    
    $Global:arrList = @()
    $Record2.MoveFirst()    
    for ($i = 0; $i -lt $Record2.RecordCount; $i++) {
        $arrTemp = @()
        for ($i2 =0 ; $i2 -lt $Record2.Fields.Count ; $i2++ ) {
            $arrTemp += $Record2.Fields.Item($i2).Value
            if (( $i2 -eq 4 ) -and ($Record2.Fields.Item($i2).Value -eq '1')) { $Global:CorrectAnsver = $i; Write-Host "cor" ; Write-Host $Global:CorrectAnsver}
        }    
    $Global:arrList += , $arrTemp
    $Record2.MoveNext()
    }    
}

$Conn = New-Object -Com ADODB.Connection
$ConnStr = "Provider=SQLOLEDB.1;
        Data Source=DESKTOP-3SUJGMR;
        Initial catalog=TestBase;
        Integrated Security = SSPI;"

        #Data Source=DESKTOP-JV090M4;
$Conn.Open($ConnStr)

# Добавить получение ФИО из vbs
#******************************
$ComputerName =$env:COMPUTERNAME
$UserName = $env:USERNAME

# Если новый пользователь добавляем с количеством правильных ответов 3
$Record = New-Object -com ADODB.Recordset
$Record.Open("Select Count(*) From ADUsers Where UserAD = '$UserName' ", $Conn, 3)
if ($Record.Fields.Item(0).Value -eq 0) {
    $QueryAddUser = "Insert into ADUsers (Name_FIO, UserAD, Count_Ansvers, Date_Add) Values ('', '$UserName', '3', GetDate())"
    $Conn.Execute($QueryAddUser)
}
$Record.Close()

# Получаем данные пользователя
$Record.Open("Select * From ADUsers Where UserAD = '$UserName' ", $Conn, 3)
#$CountTrueAnsvers = $Record.Fields.Item("Count_Ansvers").Value
# *********************************

# Получаем уникальный ключ для управлениями записями
#$CSID_Session
$CSID_Session =  $Conn.Execute("Declare @ID UNIQUEIDENTIFIER;Set @ID = NEWID();Select @ID;").Fields.Item(0).Value
# Уникальная запись для сессии и связанной таблицы истории
# Добавляем запись сессии с базой
$Query = "Insert into Sessions (ID_Ses, Computer, Start_Session, ADUser) Values ('$CSID_Session', '$ComputerName', GetDate(), '$UserName')"
$Conn.Execute($Query) |Out-Null

# Переменные
#$ID_Question # Текущий вопрос 
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Windows.Forms, WindowsBase

<#[xml]$xmlModal = '
<Page 
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      
      xmlns:d="http://schemas.microsoft.com/expression/blend/2008" 
      xmlns:local="clr-namespace:ESUPB"
      
      DesignHeight="270" DesignWidth="620"
      Title="Page1">
    <Grid>
        <Border CornerRadius="20" BorderBrush="#FF195E8F" Background="#FF4B9ED6" BorderThickness="2">
            <StackPanel>
                <TextBox TextAlignment="Center" HorizontalAlignment="Center" Margin="0,50,0,70" 
                         Text="У Вас не выбран ни один ответ.&#xa;Выберите, пожалуйста, ответ." BorderBrush="{x:Null}"
                         FontFamily="Arial" FontSize="20" FontWeight="Bold" Background="#FF4B9ED6" Foreground="White">
                </TextBox>
                <StackPanel Width="190" Height="70">
                    <Border CornerRadius="6" BorderBrush="#FF195E8F" Background="#FF2184CB" BorderThickness="2">
                        <Button Content="ДАЛЕЕ" Background="#FF195E8F" Width="190" Height="60" BorderBrush="#FF195E8F" 
                            FontFamily="Arial" FontSize="20" FontWeight="Bold" Foreground="White"/>
                    </Border>
                </StackPanel>
            </StackPanel>
        </Border>
    </Grid>
</Page>
'
#>

[xml]$xmlResult = '
<Window x:Class="System.Windows.Window"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        xmlns:local="clr-namespace:ESUPB"
       
        WindowStyle="None"
        ResizeMode="NoResize"
        Topmost="True"
        Title="Программа тестирования" Background="White"
        WindowStartupLocation="CenterScreen"
        WindowState="Maximized">
        <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="5*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="6*"/>
            <RowDefinition Height="0.3*"/>
            <RowDefinition Height="0.3*"/>
            <RowDefinition Height="0.3*"/>
        </Grid.RowDefinitions>
        <DockPanel Background="White" Margin="10">
            <Image x:Name="IconRes" Margin="5,10"/>
        </DockPanel>
        <DockPanel Grid.Column="1" Background="White" Margin="10">
            <TextBlock TextAlignment="Center" TextWrapping="Wrap" Margin="60,15,60,0" HorizontalAlignment="Center" VerticalAlignment="Bottom" Foreground="#0070c0">
                 <Run FontFamily="Arial" FontSize="30" FontWeight="Bold">Результат тестирования</Run>
            </TextBlock>
        </DockPanel>
        <StackPanel Grid.Column="2" Background="White" Margin="10">
            <TextBox TextAlignment="Center" TextWrapping="Wrap" Margin="15,25" HorizontalAlignment="Center" VerticalAlignment="Center"
                Text="{Binding Source={x:Static sys:DateTime.Now}, Mode=OneWay, StringFormat={}{0:dd/MM/yyyy}, ConverterCulture=ru}"
                FontFamily="Arial" FontSize="22" FontWeight="Bold" BorderBrush="{x:Null}" Background="{x:Null}" Foreground="#FF363636">
            </TextBox>
        </StackPanel>
        <StackPanel Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="3" Margin="250,0,250,250" Height="250" >
            <DockPanel>
               <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="#0070c0" BorderThickness="2" DockPanel.Dock="Top">
               <TextBlock x:Name="txtComplete" Margin="20,100" TextWrapping="Wrap" HorizontalAlignment="Center" 
                       FontFamily="Arial" FontSize="20" FontWeight="Bold" 
                       Text="               Вы успешно прошли проверку знаний требований ЕСУПБ.&#xa;Из предложенных Вам 3 вопросов Вы ответили правильно на 3 вопроса." 
                       Foreground="White" />
               </Border>
            </DockPanel>
        </StackPanel>
        <DockPanel Grid.Column="0" Grid.Row="2" Grid.RowSpan="3" Margin="10">
            <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="#FF2184CB" BorderThickness="2" DockPanel.Dock="Top">
                <Button x:Name="butEmpty" Content="" Background="#FF195E8F" FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="White"/>
            </Border>
        </DockPanel>
        <Border Grid.Column="1" Grid.Row="2" Grid.RowSpan="3" CornerRadius="6" BorderBrush="#FF0070C0" Background="#0070c0" 
                BorderThickness="2" >
            <StackPanel Margin="5,10">
            <Label x:Name="leiUserRes" Grid.Column="1" Grid.Row="3" Background="#0070c0" HorizontalContentAlignment="Center" Content="Иванов Иван Иванович"
                FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
            <Label x:Name="leiPositionRes" Grid.Column="1" Grid.Row="4" Background="#0070c0" HorizontalContentAlignment="Center" Content="инженер ПТО"
                FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
            <Label x:Name="leiUnitRes" Grid.Column="1" Grid.Row="5" Background="#0070c0" HorizontalContentAlignment="Center" Content="ЭПУ &quot;Зеленодольскгаз&quot;"
                FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
    </StackPanel>
        </Border>
        <DockPanel Grid.Column="2" Grid.Row="2" Grid.RowSpan="3" Background="#FFC4C4C4" Margin="10" VerticalAlignment="Center">
            <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="#FF2184CB" BorderThickness="2" DockPanel.Dock="Top">
                <Button x:Name="butComplete" Content="   Завершить&#xa;тестирование" Background="#FF195E8F" Height="100"
                    FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="White"/>
            </Border>
        </DockPanel>
    </Grid>
</Window>
' 

[xml]$xmlAnsvers = '
<Window 
        x:Class="System.Windows.Window"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        xmlns:local="clr-namespace:ESUPB"
        Topmost="True"
        WindowStyle="None"
        ResizeMode="NoResize"
        Title="Программа тестирования" Background="White"
        WindowStartupLocation="CenterScreen"
        WindowState="Maximized">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="5*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="2*"/>
            <RowDefinition Height="4*"/>
            <RowDefinition Height="0.3*"/>
            <RowDefinition Height="0.3*"/>
            <RowDefinition Height="0.3*"/>
        </Grid.RowDefinitions>

        <DockPanel Background="White" Margin="10">
            <Image x:Name="Icon" Margin="5,10"/>
        </DockPanel>

        <DockPanel Grid.Column="1" Background="White" Margin="10">
            <TextBlock TextAlignment="Center" TextWrapping="Wrap" Margin="60,15" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#0070c0">
                <Run FontFamily="Arial" FontSize="30" FontWeight="Bold">Система сопутствующего тестирования знаний ОТ, ПиПБ, БДД</Run>
            </TextBlock>
        </DockPanel>

        <StackPanel Grid.Column="2" Background="White" Margin="10">
            <TextBox TextAlignment="Center" TextWrapping="Wrap" Margin="15,25" HorizontalAlignment="Center" VerticalAlignment="Center"
                Text="{Binding Source={x:Static sys:DateTime.Now}, Mode=OneWay, StringFormat={}{0:dd/MM/yyyy}, ConverterCulture=ru}"
                FontFamily="Arial" FontSize="22" FontWeight="Bold" BorderBrush="{x:Null}" Background="{x:Null}" Foreground="#FF363636">
            </TextBox>
        </StackPanel>

        <StackPanel Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="3" Margin="20,30,20,10">
            <Label Content="Вопрос" x:Name="txtCountQuestion" Margin="90,0,0,0" HorizontalAlignment="Left" FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="#FF363636"/>
            <DockPanel Margin="20,0">
                <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="White" BorderThickness="2" DockPanel.Dock="Top">
                <TextBlock x:Name="txtblQuestion" Margin="100,10,100,5" TextWrapping="Wrap" Height="100" Background="White" 
                    HorizontalAlignment="Center" VerticalAlignment="Center"
                    FontFamily="Arial" FontSize="20" FontWeight="Bold" Text="Что понимается под вредным производственным фактором?"/>
                </Border>
            </DockPanel>
        </StackPanel>

        <StackPanel Grid.Column="0" Grid.Row="2" Grid.ColumnSpan="3">
            <Label Content="Выберите правильный ответ:" HorizontalAlignment="Center" 
                FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="#0070c0"/>
            <ScrollViewer>

                        <StackPanel x:Name="StackPanelradBtn">
                            

                        </StackPanel>

            </ScrollViewer>                    
                <TextBox x:Name="txtBoxCorrectAnswer" Margin="120,50" TextWrapping="Wrap" VerticalAlignment="Center" BorderBrush="{x:Null}" 
                    FontFamily="Arial" FontSize="20" >
                    Фактор среды и трудового процесса, воздействие которого на работника может вызывать профессиональное заболевание или другое нарушение состояния здоровья, повреждение здоровья потомства.
                </TextBox>
        </StackPanel>
        <DockPanel Grid.Column="0" Grid.Row="3" Grid.RowSpan="3" Margin="10">
            <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="#FF2184CB" BorderThickness="2" DockPanel.Dock="Top">
                <Button x:Name="butSkip" Content="" Background="#FF195E8F" FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="White"/>
            </Border>
        </DockPanel>
        <Border Grid.Column="1" Grid.Row="3" Grid.RowSpan="3" CornerRadius="6" BorderBrush="#FF0070C0" Background="#0070c0"
                BorderThickness="2">
            <StackPanel Margin="5,5">
                <Label x:Name="leiUser" Grid.Column="1" Grid.Row="3" Background="#0070c0" HorizontalContentAlignment="Center" Content="Иванов Иван Иванович"
                    FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
                <Label x:Name="leiPosition" Grid.Column="1" Grid.Row="4" Background="#0070c0" HorizontalContentAlignment="Center" Content="инженер ПТО"
                    FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
                <Label x:Name="leiUnit" Grid.Column="1" Grid.Row="5" Background="#0070c0" HorizontalContentAlignment="Center" Content="ЭПУ &quot;Зеленодольскгаз&quot;"
                    FontFamily="Arial" FontSize="20" FontWeight="Bold" FontStyle="Italic" Foreground="White"/>
            </StackPanel>
        </Border>    
        <DockPanel Grid.Column="2" Grid.Row="3" Grid.RowSpan="3" Background="#FFC4C4C4" Margin="10">
            <Border CornerRadius="6" BorderBrush="#FF0070C0" Background="#FF2184CB" BorderThickness="2" DockPanel.Dock="Top">
                <Button x:Name="butNext" Content="Проверить" Background="#FF195E8F" FontFamily="Arial" FontSize="24" FontWeight="Bold" Foreground="White"/>
            </Border>    
        </DockPanel>
    </Grid>
</Window>
'
$Global:xamGui = [System.Windows.Markup.XamlReader]::Load(( New-Object System.Xml.XmlNodeReader $xmlAnsvers))
$Global:xamRes = [System.Windows.Markup.XamlReader]::Load(( New-Object System.Xml.XmlNodeReader $xmlResult))
#$Global:xamMod = [System.Windows.Markup.XamlReader]::Load(( New-Object System.Xml.XmlNodeReader $xmlModal))  

# Загрузка элементов управления списком
$xmlAnsvers.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object{
    Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
}
$xmlResult.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object{
    Set-Variable -Name ($_.Name) -Value $xamRes.FindName($_.Name) -Scope Global
}
# $xmlModal.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object{
#     Set-Variable -Name ($_.Name) -Value $xamMod.FindName($_.Name) -Scope Global
# }

$Icon.Source = $PSScriptRoot + "e:\ESUPB\WPF_Form2\icon.jpg"
$IconRes.Source = $PSScriptRoot + "e:\ESUPB\WPF_Form2\icon.jpg"

#[System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$AD = [System.DirectoryServices.DirectorySearcher]::new()
$AD.Filter = "(&(objectClass=person)(samaccountname=$env:USERNAME))"
$UserInfo = $AD.FindOne().Properties
#$User = gwmi win32_account -Filter "name='$env:USERNAME'"

$leiUser.Content = $UserInfo.displayname.Item(0)
$leiPosition.Content = $UserInfo.Title.Item(0)
$leiUnit.Content = $UserInfo.Departament.Item(0)
$leiUserRes.Content = $UserInfo.displayname.Item(0)
$leiPositionRes.Content = $UserInfo.Title.Item(0)
$leiUnitRes.Content = $UserInfo.Departament.Item(0)

$txtBoxCorrectAnswer.Text = ""
$txtBoxCorrectAnswer.TextWrapping = "Wrap"
$CountQusetion = $Global:CountQuestion+1
$txtCountQuestion.Content = "Вопрос $CountQusetion из 3"

$Program = "1" # Разделы вопросов На SQL
# Получение общего количества вопросов
$Record = New-Object -com ADODB.Recordset
$Record.Open("Select * From Question Where Active = 1 And ID_Program = $Program", $Conn, $OpenStatic)

# Добавить проверку на не пустой запрос
# *************************************

# Получаем массив вопросов для последующей случайной выборки
$Global:ArrQuestions = @()
$Record.MoveFirst()
While (!$Record.EOF) {         
    $Global:ArrQuestions += $Record.Fields.Item(0).Value
    $Record.MoveNext()
}
$Record.Close()

#$Global:arrList = @()

Get-Qusetion
Out-PanelAnsvers
#$ret = Get-Qusetion
#$ArrQuestions = $ret[0]
#$arrList = $ret[1]
#$CorrectAnsver = $ret[2]

#Write-Host $Global:CorrectAnsver
function Check-test {

    $valu = $false
    $ListRadioButton = $StackPanelradBtn.Children
    #$ListRadioButton[0].Children[1].Children[0].IsChecked

    for ($i = 0; $i -lt $ListRadioButton.Count ; $i++) {
        if ($ListRadioButton[$i].Children[1].Children[0].IsChecked -and ($Global:CorrectAnsver -eq $i)) {
            $valu=$true
        }
        # if ($ListRadioButton[$i].IsChecked -and ($Global:CorrectAnsver -eq $i) ) {
        #     $valu=$true
        # }
    }

    return $valu

}

# Вывод результата итогов тестирования
function Watch-Question {    


    $valu = Check-test
    #Write-host $Global:CorrectCounter
    #Write-host $Global:CountQuestion

    foreach ($i in $ListRadioButton) {
        #$i.IsChecked = $false
        $i.Children[1].Children[0].IsChecked = $false
    }
    

    if ($valu) { $Global:CorrectCounter += 1 }    

    if ($Global:CountQuestion -eq 3) {        
        #ShowMess
        if ($Global:CorrectCounter -ge 2 ) {
        
            $txtComplete.Text = "Вы успешно прошли проверку знаний требований ЕСУПБ. Правильных ответов $Global:CorrectCounter из 3."
            $butComplete.Content ="ЗАВЕРШИТЬ"

        } else {
            
            $txtComplete.Text = "Вы не прошли проверку знаний требований ЕСУПБ. Правильных ответов $Global:CorrectCounter из 3."
            $butComplete.Content ="ЗАНОВО"
            
        }

        $xamGui.Hide()
        $xamRes.ShowDialog() | Out-Null
        
    }

    Get-Qusetion
#    $ArrQuestions = $ret[0]
    #$CorrectAnsver = $ret[2]
    #$arrList = $ret[1]

    Out-PanelAnsvers

    #Write-Host $Global:CorrectAnsver
    # Запись ответа в базу    
    #********************

}

$butComplete.Add_Click({

    # Если 2 правильных ответа закрыть программу иначе новая порция вопросов
    if ($Global:CorrectCounter -ge 2 ) {
        
        $xamGui.Close()
        $xamRes.Close()

    } else {

        $Global:CorrectCounter = 0        
        $Global:CountQuestion = 0
        $CountQusetion = $Global:CountQuestion+1
        $txtCountQuestion.Content = "Вопрос $CountQusetion из 3"
        Get-Qusetion
        Out-PanelAnsvers
        $xamRes.Hide()
        $xamGui.ShowDialog()        
    }

})

$butNext.Add_Click({

    $val = $false
    $ImageCorrect = New-Object System.Windows.Controls.Image
    $ImageCorrect.Source = $PSScriptRoot + "\ImgCorrect.jpg"
    $ImageCorrect.Stretch = "Fill"
    $ImageFalse = New-Object System.Windows.Controls.Image
    $ImageFalse.Stretch = "Fill"
    $ImageFalse.Source = $PSScriptRoot + "\ImgFalse.jpg"    

    $ListRadioButton = $StackPanelradBtn.Children

    # Если ответ не выбран ничего не делаем
    foreach ($item in $ListRadioButton) {
        #if ($item.IsChecked) {$val = $true; break}
        if ($item.Children[1].Children[0].IsChecked) {$val = $true; break}
        
    }
    # Если ответ не выбран пропускаем
    If ($val) {

        # Ответ выбран, проверяем верный или не верный ответ
        $corr = Check-test

        # Для демонтрируем правильный/или неправильный ответ и записи в базу результата
        if ($CheckAnsvers) {
        
            # Блок вывода экрана подсказки
            $CheckAnsvers = $false #Тригер демонстрации подсказки

            # Если ответ не верный выводим подсказку
            if (!$corr) { 

                # Выводим подсказку правильного ответа 
                $txtBoxCorrectAnswer.Text = $Global:arrList[$Global:CorrectAnsver].Item(1)
                # Блокируем возможность менять ответ
                foreach ($item0 in $ListRadioButton) {
                    $item0.Children[1].Children[0].IsEnabled = $false
                }
                
                $butNext.Content = "Далее" 
                # Выводим пиктограмму на неправильным ответе
                for ($i = 0; $i -lt $ListRadioButton.Count; $i++) {
                    if ($ListRadioButton[$i].Children[1].Children[0].IsChecked) {
                        #$ListRadioButton[$i].Children[0].Background = "Red"
                        $ListRadioButton[$i].Children[0].Content = $ImageFalse
                        $ListRadioButton[$i].Children[0].Visibility = "Visible"
                    }
                }
                
            } else { # Если ответ верный выводим соответствующий экран

                # Блокируем выбор ответа 
                foreach ($item0 in $ListRadioButton) {
                    $item0.Children[1].Children[0].IsEnabled = $false
                    #$item0.IsEnabled = $false
                }

                # Выводим пиктограмму на правильном ответе
                for ($i = 0; $i -lt $ListRadioButton.Count; $i++) {
                    if ($ListRadioButton[$i].Children[1].Children[0].IsChecked) {
                        #$ListRadioButton[$i].Children[0].Background = "Green"
                        $ListRadioButton[$i].Children[0].Content = $ImageCorrect
                        $ListRadioButton[$i].Children[0].Visibility = "Visible"
                    }
                }

                $butNext.Content = "Далее" 
                
            }
            
        } else { 
            # Блок вывода вопросов
            
            # скрываем подсказки и выводим новый вопросов
            # Переключаем Тригер демонстрации подсказки
            $CheckAnsvers = $true 
            # скрываем подсказку
            $txtBoxCorrectAnswer.Text = ""             
            #  счетчик вопросов увеличиваем на 1
            $Global:CountQuestion += 1 

            $CountQusetion = $Global:CountQuestion + 1
            $txtCountQuestion.Content = "Вопрос $CountQusetion из 3"
            $butNext.Content = "Проверить" 
            
            # Запрашиваем новый вопрос
            Watch-Question

        }

    }

})

$xamGui.ShowDialog() | Out-Null

<# # Вывод последней сессии
$que = 'SELECT TOP 1 [ID_Ses] ,[ID_ADUsers] ,[Computer] ,[Start_Session] ,[ADUser]
  FROM [TestBase].[dbo].[Sessions]
  ORDER by [Start_Session] DESC' 

# Вывод связанной таблицы
$que2 = '
SELECT [ID_His] ,[ID_Sessions] ,[DateTime_Ansver] ,[ID_Question] ,[Successfully]
  ,[ID_Ses] ,[ID_ADUsers] ,[Computer] ,[Start_Session] ,[ADUser]
  FROM [TestBase].[dbo].[Sessions] Left join [TestBase].[dbo].[History_Quest]  ON [ID_Sessions] = [ID_Ses]
  Where [ID_Ses] in (SELECT TOP 1 [ID_Ses]
  FROM [TestBase].[dbo].[Sessions]
  ORDER by [Start_Session] DESC)
  '
 #>

#  $sc = New-Object -ComObject MSScriptControl.ScriptControl.1
#  $sc.Language = 
#  $sc.AddCode('
#     adsi = CreateObject("ADSystemInfo")
#     Set un = GetObject("LDAP://" & adsi.Username)
#     UserPosition = un.title
#  ')
