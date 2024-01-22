$color_src = 'C:\Users\nuker\vimfiles\plugged\vim-colorschemes\colors'
$color_des = 'C:\Users\nuker\Documents\DarkAlessa\dotfiles\vim\colors'

$vimrc_src = 'C:\Users\nuker'
$vimrc_des = 'C:\Users\nuker\Documents\DarkAlessa\dotfiles\vim'

if ($(date -r $color_src\mimic.vim) -eq $(date -r $color_des\mimic.vim)) {
	Write-Output "mimic.vim is already up-to-date."
}
else 
{
	Copy-Item -Path "$color_src\mimic.vim" -Destination "$color_des"
	Write-Output "Updated mimic.vim"
}

if ($(date -r $vimrc_src\.vimrc) -eq $(date -r $vimrc_des\.vimrc)) {
	Write-Output ".vimrc is already up-to-date."
}
else 
{
	Copy-Item -Path "$vimrc_src\.vimrc" -Destination "$vimrc_des"
	Write-Output "Updated .vimrc"
}

date >> C:\Users\nuker\Desktop\backup-date.txt
