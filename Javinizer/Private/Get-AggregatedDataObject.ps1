function Get-AggregatedDataObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [object]$FileDetails,
        [object]$UrlLocation,
        [switch]$R18,
        [switch]$Dmm,
        [switch]$Javlibrary,
        [object]$Settings,
        [string]$Id
    )

    process {
        $actressPriority = Get-MetadataPriority -Settings $Settings -Type 'actress'
        $actressthumburlPriority = Get-MetadataPriority -Settings $Settings -Type 'actressthumburl'
        $alternatetitlePriority = Get-MetadataPriority -Settings $Settings -Type 'alternatetitle'
        $coverurlPriority = Get-MetadataPriority -Settings $Settings -Type 'coverurl'
        $descriptionPriority = Get-MetadataPriority -Settings $Settings -Type 'description'
        $directorPriority = Get-MetadataPriority -Settings $Settings -Type 'director'
        $genrePriority = Get-MetadataPriority -Settings $Settings -Type 'genre'
        $idPriority = Get-MetadataPriority -Settings $Settings -Type 'id'
        $labelPriority = Get-MetadataPriority -Settings $Settings -Type 'label'
        $runtimePriority = Get-MetadataPriority -Settings $Settings -Type 'runtime'
        $makerPriority = Get-MetadataPriority -Settings $Settings -Type 'maker'
        $titlePriority = Get-MetadataPriority -Settings $Settings -Type 'title'
        $ratingPriority = Get-MetadataPriority -Settings $Settings -Type 'rating'
        $releasedatePriority = Get-MetadataPriority -Settings $Settings -Type 'releasedate'
        $releaseyearPriority = Get-MetadataPriority -Settings $Settings -Type 'releaseyear'
        $seriesPriority = Get-MetadataPriority -Settings $Settings -Type 'series'
        $screenshoturlPriority = Get-MetadataPriority -Settings $Settings -Type 'screenshoturl'

        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $R18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $Dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $Javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }

        if ($UrlLocation) {
            $currentSearch = $UrlLocation.Url
            foreach ($url in $UrlLocation) {
                if ($url.Result -contains 'r18') {
                    $r18Data = Get-R18DataObject -Url $url.Url
                }

                if ($url.Result -contains 'dmm') {
                    $dmmData = Get-DmmDataObject -Url $url.Url
                }

                if ($url.Result -contains 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Url $url.Url
                }
            }
        } elseif ($FileDetails) {
            $currentSearch = $FileDetails.Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $fileDetails.Id
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $fileDetails.Id
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id
            }
        } elseif ($PSBoundParameters.ContainsKey('Id')) {
            $currentSearch = $Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $Id
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $Id
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $Id
            }
        }

        $aggregatedDataObject = [pscustomobject]@{
            Id              = $null
            Title           = $null
            AlternateTitle  = $null
            Description     = $null
            ReleaseDate     = $null
            ReleaseYear     = $null
            Runtime         = $null
            Director        = $null
            Maker           = $null
            Label           = $null
            Series          = $null
            Rating          = $null
            Actress         = $null
            Genre           = $null
            ActressThumbUrl = $null
            CoverUrl        = $null
            ScreenshotUrl   = $null
            DisplayName     = $null
            FileName        = $null
            FolderName      = $null
        }

        foreach ($priority in $actressPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Actress) {
                $aggregatedDataObject.Actress = $var.Value.Actress
            }
        }

        foreach ($priority in $actressthumburlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ActressThumbUrl) {
                $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
            }
        }

        foreach ($priority in $alternatetitlePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.AlternateTitle) {
                $aggregatedDataObject.AlternateTitle = $var.Value.Title
            }
        }

        foreach ($priority in $coverurlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.CoverUrl) {
                $aggregatedDataObject.CoverUrl = $var.Value.CoverUrl
            }
        }

        foreach ($priority in $descriptionPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Description) {
                if ($Settings.Metadata.'translate-description' -eq 'true' -and $null -ne $var.Value.Description) {
                    $translatedDescription = Get-TranslatedString $var.Value.Description
                    $aggregatedDataObject.Description = $translatedDescription
                } else {
                    $aggregatedDataObject.Description = $var.Value.Description
                }
            }
        }

        foreach ($priority in $directorPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Director) {
                $aggregatedDataObject.Director = $var.Value.Director
            }
        }

        foreach ($priority in $genrePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Genre) {
                $aggregatedDataObject.Genre = $var.Value.Genre
            }
        }

        foreach ($priority in $idPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Id) {
                $aggregatedDataObject.Id = $var.Value.Id
            }
        }

        foreach ($priority in $labelPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Label) {
                $aggregatedDataObject.Label = $var.Value.Label
            }
        }

        foreach ($priority in $runtimePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Runtime) {
                $aggregatedDataObject.Runtime = $var.Value.Runtime
            }
        }

        foreach ($priority in $makerPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Maker) {
                $aggregatedDataObject.Maker = $var.Value.Maker
            }
        }

        foreach ($priority in $titlePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Title) {
                $aggregatedDataObject.Title = $var.Value.Title
            }
        }

        foreach ($priority in $ratingPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Rating) {
                $aggregatedDataObject.Rating = $var.Value.Rating
            }
        }

        foreach ($priority in $releasedatePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ReleaseDate) {
                $aggregatedDataObject.ReleaseDate = $var.Value.Date
            }
        }

        foreach ($priority in $releaseyearPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ReleaseYear) {
                $aggregatedDataObject.ReleaseYear = $var.Value.Year
            }
        }

        foreach ($priority in $seriesPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Series) {
                $aggregatedDataObject.Series = $var.Value.Series
            }
        }

        foreach ($priority in $screenshoturlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ScreenshotUrl) {
                $aggregatedDataObject.ScreenshotUrl = $var.Value.ScreenshotUrl
            }
        }

        $fileDirName = Get-NewFileDirName -DataObject $aggregatedDataObject
        $aggregatedDataObject.FileName = $fileDirName.FileName
        $aggregatedDataObject.FolderName = $fileDirName.FolderName
        $aggregatedDataObject.DisplayName = $fileDirName.DisplayName

        Write-Output $aggregatedDataObject
    }
}