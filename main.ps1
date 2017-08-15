Param(
    [parameter(Mandatory = $true)]
    [alias("s")]
    $StorageDir,
    [alias("k")]
    $ApiKey = "DEMO_KEY")

#Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$url = "https://api.nasa.gov/planetary/apod?api_key=$ApiKey"
$result = Invoke-RestMethod -Uri $url -Method Get;

$webclient = New-Object System.Net.WebClient

#Create directory if it doesn't exist
If (!(test-path $StorageDir)) {
    New-Item -ItemType Directory -Force -Path $StorageDir
}

$fileName = "apod.jpg"
$file = "$StorageDir\$fileName"

$webclient.DownloadFile($result.hdurl, $file)

Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
   public enum Style : int
   {
       Tile, Center, Stretch, NoChange
   }
   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
         switch( style )
         {
            case Style.Stretch :
               key.SetValue(@"WallpaperStyle", "2") ; 
               key.SetValue(@"TileWallpaper", "0") ;
               break;
            case Style.Center :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "0") ; 
               break;
            case Style.Tile :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "1") ;
               break;
            case Style.NoChange :
               break;
         }
         key.Close();
      }
   }
}
"@

[Wallpaper.Setter]::SetWallpaper( $file , 3 )