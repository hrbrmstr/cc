# cc

Extract metadata of a specific target based on the results of "commoncrawl.org"

An R clone of [`cc.py`](https://github.com/si9int/cc.py) with some differences:

- The Common Crawl is a free service but it costs real money to run so this doesn't abuse it and forces the caller to be the abuser vs enabling it with bad default behaviour
- You get all the CDX metadata back in [ndjson](http://ndjson.org/) format which can be easily processed with `jq`, scripts or compiled/interpred languages

This is a command-line utility vs a package since we don't have enough R-based command-line utility pacakges. Eventually, this will be a package with a command-line utility installer.

## Install

    git clone git@gitlab.com:hrbrmstr/cc
    cd cc

    # ensure needed pkgs are installed and that cc.R is executable
    Rscript preflight.R # or ./preflight.R if the git clone didn't mangle the executable status

## Usage

Here are the available options:

    usage: ./cc.R [--] [--help] [--list] [--opts OPTS] [--domain DOMAIN] [--out OUT] [--index INDEX]

    Extract metadata of a specific target based on the results of "commoncrawl.org"

    Examples:

    $ ./cc.R --list                                      # list indices
    $ ./cc.R --domain github.com                         # defaults to most recent index
    $ ./cc.R --domain github.com --out /tmp/gh.json      # specify an oputput file
    $ ./cc.R --index CC-MAIN-2018-34 --domain github.com # specify which index


    flags:
      -h, --help      show this help message and exit
      -l, --list      list all available indexes

    optional arguments:
      -x, --opts OPTS     RDS file containing argument values
      -d, --domain DOMAIN     domain which will be crawled
      -o, --out OUT     specify an output file (default: domain.json)
      -i, --index INDEX     use a specific index file

## Example

    ./cc.R --domain "hilton.com" --out ~/Data/hilton.json 

OR

    Rscript cc.R --domain "hilton.com" --out ~/Data/hilton.json 

Now, use `hilton.json` in R to extact all the unique subdomains:

    library(magrittr)
     
    jsonlite::stream_in(file("/tmp/hilton.json"), verbose = FALSE) %>%
      dplyr::distinct(url) %>%
      dplyr::pull(url) %>%
      stringr::str_replace("^http[s]*://", "") %>% # urltools::domain() messes up
      stringr::str_replace("[\\.]*/.*$", "") %>% # and httr::parse_url() is too slow
      stringr::str_to_lower() %>%
      unique() %>%
      sort()
    ##   [1] "abudhabi.hilton.com"                    "alain.hilton.com"                      
    ##   [3] "alexandriaoldtown.hilton.com"           "alhamrabeachandgolfresort.hilton.com"  
    ##   [5] "americashouston.hilton.com"             "amsterdamairportschiphol.hilton.com"   
    ##   [7] "anatole.hilton.com"                     "anchorage.hilton.com"                  
    ##   [9] "antlerscoloradosprings.hilton.com"      "antwerp.hilton.com"                    
    ##  [11] "apac.hilton.com"                        "ar-ae-hiltonworldwide3.hilton.com"     
    ##  [13] "ar.hilton.com"                          "arlingtontx.hilton.com"                
    ##  [15] "arlingtonva.hilton.com"                 "arubacaribbean.hilton.com"             
    ##  [17] "athens.hilton.com"                      "atlanta.hilton.com"                    
    ##  [19] "atlantamarietta.hilton.com"             "auckland.hilton.com"                   
    ##  [21] "austin.hilton.com"                      "baltimore.hilton.com"                  
    ##  [23] "baltimoreairport.hilton.com"            "bandung.hilton.com"                    
    ##  [25] "bangaloreresidences.hilton.com"         "barcelona.hilton.com"                  
    ##  [27] "barrariodejaneiro.hilton.com"           "basel.hilton.com"                      
    ##  [29] "bayclub.hilton.com"                     "beiruthabtoorgrand.hilton.com"         
    ##  [31] "bentleymiamisouthbeach.hilton.com"      "bocaratonsuites.hilton.com"            
    ##  [33] "bodrumturkbuku.hilton.com"              "bonn.hilton.com"                       
    ##  [35] "bostondedham.hilton.com"                "bostonlogan.hilton.com"                
    ##  [37] "brentwood.hilton.com"                   "brisbane.hilton.com"                   
    ##  [39] "budapest.hilton.com"                    "buenosaires.hilton.com"                
    ##  [41] "cairns.hilton.com"                      "canarywharf.hilton.com"                
    ##  [43] "canopy.hilton.com"                      "canopy3.hilton.com"                    
    ##  [45] "capital.hilton.com"                     "capitalgrandabudhabi.hilton.com"       
    ##  [47] "caribe.hilton.com"                      "charlotte.hilton.com"                  
    ##  [49] "charlottecentercity.hilton.com"         "charlotteuniversity.hilton.com"        
    ##  [51] "checkerslosangeles.hilton.com"          "chicagomagnificentmile.hilton.com"     
    ##  [53] "chicagonorthbrook.hilton.com"           "chicagooakbrookhills.hilton.com"       
    ##  [55] "cincinnatinetherlandplaza.hilton.com"   "collegestation.hilton.com"             
    ##  [57] "columbiacenter.hilton.com"              "columbusdowntown.hilton.com"           
    ##  [59] "columbuspolaris.hilton.com"             "concord.hilton.com"                    
    ##  [61] "conradhotels.hilton.com"                "conradhotels1.hilton.com"              
    ##  [63] "conradhotels3.hilton.com"               "cr.hilton.com"                         
    ##  [65] "cs-cz-hiltonworldwide3.hilton.com"      "curiocollection.hilton.com"            
    ##  [67] "curiocollection3.hilton.com"            "cyprus.hilton.com"                     
    ##  [69] "d3.hilton.com"                          "da-dk-hiltonworldwide3.hilton.com"     
    ##  [71] "dartford.hilton.com"                    "de-de-hiltonworldwide3.hilton.com"     
    ##  [73] "deerfieldbeach.hilton.com"              "denverinverness.hilton.com"            
    ##  [75] "designinformation.hilton.com"           "dfwlakes.hilton.com"                   
    ##  [77] "directconnect.hilton.com"               "discover.hilton.com"                   
    ##  [79] "doha.hilton.com"                        "doubletree.hilton.com"                 
    ##  [81] "doubletree1.hilton.com"                 "doubletree3.hilton.com"                
    ##  [83] "drake.hilton.com"                       "dresden.hilton.com"                    
    ##  [85] "durban.hilton.com"                      "durham.hilton.com"                     
    ##  [87] "ebm.h1.hilton.com"                      "embassysuites.hilton.com"              
    ##  [89] "embassysuites1.hilton.com"              "embassysuites3.hilton.com"             
    ##  [91] "es-xm-hiltonworldwide3.hilton.com"      "eugene.hilton.com"                     
    ##  [93] "explore.hilton.com"                     "families.hilton.com"                   
    ##  [95] "fd.hilton.com"                          "fivefeettofitness.hilton.com"          
    ##  [97] "fontainebleau.hilton.com"               "fortcollins.hilton.com"                
    ##  [99] "fortworth.hilton.com"                   "fr-fr-hiltonworldwide3.hilton.com"     
    ## [101] "ftwayne.hilton.com"                     "gaithersburg.hilton.com"               
    ## [103] "gatwick.hilton.com"                     "glasgow.hilton.com"                    
    ## [105] "glendale.hilton.com"                    "golf.hilton.com"                       
    ## [107] "goout.hilton.com"                       "greenvillesc.hilton.com"               
    ## [109] "group.hilton.com"                       "groupguides.hilton.com"                
    ## [111] "guangzhoutianhe.hilton.com"             "hamptoninn.hilton.com"                 
    ## [113] "hamptoninn1.hilton.com"                 "hamptoninn3.hilton.com"                
    ## [115] "hanoi.hilton.com"                       "harrisburg.hilton.com"                 
    ## [117] "hawaiianvillage.hilton.com"             "heathrow.hilton.com"                   
    ## [119] "helsinki-strand.hilton.com"             "hhonors.hilton.com"                    
    ## [121] "hhonors1.hilton.com"                    "hhonors3.hilton.com"                   
    ## [123] "hilton.com"                             "hiltongardeninn.hilton.com"            
    ## [125] "hiltongardeninn1.hilton.com"            "hiltongardeninn3.hilton.com"           
    ## [127] "hiltonhonors.hilton.com"                "hiltonhonors3.hilton.com"              
    ## [129] "hiltonsuggests.hilton.com"              "hiltonworldwide.hilton.com"            
    ## [131] "hiltonworldwide1.hilton.com"            "hiltonworldwide3.hilton.com"           
    ## [133] "home2suites.hilton.com"                 "home2suites1.hilton.com"               
    ## [135] "home2suites3.hilton.com"                "homewoodsuites.hilton.com"             
    ## [137] "homewoodsuites1.hilton.com"             "homewoodsuites3.hilton.com"            
    ## [139] "houstonplaza.hilton.com"                "houstonpostoak.hilton.com"             
    ## [141] "inspiredevents.hilton.com"              "ir.hilton.com"                         
    ## [143] "irvineorangecountyairport.hilton.com"   "istanbul-park.hilton.com"              
    ## [145] "istanbul.hilton.com"                    "it-it-hiltonworldwide3.hilton.com"     
    ## [147] "ja-jp-hiltonworldwide3.hilton.com"      "jackson.hilton.com"                    
    ## [149] "jfkairport.hilton.com"                  "jobs.hilton.com"                       
    ## [151] "kansascityairport.hilton.com"           "kauaibeachresort.hilton.com"           
    ## [153] "knoxvilleairport.hilton.com"            "kuala-lumpur.hilton.com"               
    ## [155] "kuwait.hilton.com"                      "lafayette.hilton.com"                  
    ## [157] "lajollatorreypines.hilton.com"          "lakelasvegas.hilton.com"               
    ## [159] "laketaupo.hilton.com"                   "lima.hilton.com"                       
    ## [161] "lobby.hilton.com"                       "londonwembley.hilton.com"              
    ## [163] "longboatkey.hilton.com"                 "losangelesairport.hilton.com"          
    ## [165] "m.hilton.com"                           "madridairport.hilton.com"              
    ## [167] "mail.hilton.com"                        "maldivesirufushi.hilton.com"           
    ## [169] "managementservices.hilton.com"          "manchesterdeansgate.hilton.com"        
    ## [171] "mauritius.hilton.com"                   "meetings.hilton.com"                   
    ## [173] "mexicocity.hilton.com"                  "miamidowntown.hilton.com"              
    ## [175] "minneapolis.hilton.com"                 "momvoyage.hilton.com"                  
    ## [177] "moscow.hilton.com"                      "naples.hilton.com"                     
    ## [179] "nassau.hilton.com"                      "naypyitaw.hilton.com"                  
    ## [181] "newcastlegateshead.hilton.com"          "news.hilton.com"                       
    ## [183] "newsroom.hilton.com"                    "newyorkmillenium.hilton.com"           
    ## [185] "newyorktowers.hilton.com"               "ningbodongqianlakeresort.hilton.com"   
    ## [187] "northbrook.hilton.com"                  "odawara.hilton.com"                    
    ## [189] "ohare.hilton.com"                       "onqinsider.hilton.com"                 
    ## [191] "orangecountycostamesa.hilton.com"       "orlandolakebuenavista.hilton.com"      
    ## [193] "orringtonevanston.hilton.com"           "palaciodelrio.hilton.com"              
    ## [195] "palmsprings.hilton.com"                 "pasadena.hilton.com"                   
    ## [197] "pattaya.hilton.com"                     "petaling-jaya.hilton.com"              
    ## [199] "phoenixairport.hilton.com"              "phoenixchandler.hilton.com"            
    ## [201] "phoenixsuites.hilton.com"               "phuketarcadia.hilton.com"              
    ## [203] "pikesville.hilton.com"                  "pittsburgh.hilton.com"                 
    ## [205] "pl-pl-hiltonworldwide3.hilton.com"      "pleasantonattheclub.hilton.com"        
    ## [207] "podgoricacrnagora.hilton.com"           "portland.hilton.com"                   
    ## [209] "presidentkansascity.hilton.com"         "pt-br-hiltonworldwide3.hilton.com"     
    ## [211] "quito.hilton.com"                       "reg.h1.hilton.com"                     
    ## [213] "res2.hilton.com"                        "reykjaviknordica.hilton.com"           
    ## [215] "richmonddowntown.hilton.com"            "ro-ro-hiltonworldwide3.hilton.com"     
    ## [217] "romeairport.hilton.com"                 "rotterdam.hilton.com"                  
    ## [219] "ryetown.hilton.com"                     "sanbernardino.hilton.com"              
    ## [221] "sandiegoairport.hilton.com"             "sandiegobayfront.hilton.com"           
    ## [223] "sandiegodelmar.hilton.com"              "sandiegomissionvalley.hilton.com"      
    ## [225] "sanfrancisco.hilton.com"                "sanfranciscoairport.hilton.com"        
    ## [227] "santafemexico.hilton.com"               "scottsdaleresort.hilton.com"           
    ## [229] "scranton.hilton.com"                    "seattleairport.hilton.com"             
    ## [231] "secure.hilton.com"                      "secure3.hilton.com"                    
    ## [233] "sharjah.hilton.com"                     "shreveport.hilton.com"                 
    ## [235] "sibiu.hilton.com"                       "singapore.hilton.com"                  
    ## [237] "sonomawinecountry.hilton.com"           "springfieldva.hilton.com"              
    ## [239] "stay.hilton.com"                        "stockholm-slussen.hilton.com"          
    ## [241] "suppliersconnection.hilton.com"         "sydney.hilton.com"                     
    ## [243] "tapestrycollection3.hilton.com"         "teammembers.hilton.com"                
    ## [245] "th-th-hiltonworldwide3.hilton.com"      "timessquare.hilton.com"                
    ## [247] "tobago.hilton.com"                      "tokyoodaiba.hilton.com"                
    ## [249] "torontomarkham.hilton.com"              "tr-tr-hiltonworldwide3.hilton.com"     
    ## [251] "travel.hilton.com"                      "tripplanner.hilton.com"                
    ## [253] "tru.hilton.com"                         "tru3.hilton.com"                       
    ## [255] "uber.hilton.com"                        "uf.hilton.com"                         
    ## [257] "vienna-danube.hilton.com"               "vienna-plaza.hilton.com"               
    ## [259] "vienna.hilton.com"                      "waco.hilton.com"                       
    ## [261] "waldorf.hilton.com"                     "waldorfastoria.hilton.com"             
    ## [263] "waldorfastoria3.hilton.com"             "washingtondcrockville.hilton.com"      
    ## [265] "washingtondulles.hilton.com"            "westchase.hilton.com"                  
    ## [267] "westchester.hilton.com"                 "winnipegairportsuites.hilton.com"      
    ## [269] "woodlandhills.hilton.com"               "www.ar.hilton.com"                     
    ## [271] "www.batonrougecapitolcenter.hilton.com" "www.cartagena.hilton.com"              
    ## [273] "www.charlottecentercity.hilton.com"     "www.cincinnatiairport.hilton.com"      
    ## [275] "www.cologne.hilton.com"                 "www.columbuspolaris.hilton.com"        
    ## [277] "www.concord.hilton.com"                 "www.curiocollection3.hilton.com"       
    ## [279] "www.doubletree1.hilton.com"             "www.doubletree3.hilton.com"            
    ## [281] "www.goout.hilton.com"                   "www.greenvillesc.hilton.com"           
    ## [283] "www.hamptoninn.hilton.com"              "www.hamptoninn3.hilton.com"            
    ## [285] "www.hilton.com"                         "www.home2suites.hilton.com"            
    ## [287] "www.indianapolisnorth.hilton.com"       "www.jobs.hilton.com"                   
    ## [289] "www.managementservices.hilton.com"      "www.news.hilton.com"                   
    ## [291] "www.podgoricacrnagora.hilton.com"       "www.singapore.hilton.com"              
    ## [293] "www.springfieldil.hilton.com"           "www.stay.hilton.com"                   
    ## [295] "www.stlouisairport.hilton.com"          "www.stlouisballpark.hilton.com"        
    ## [297] "www.travelagents.hilton.com"            "www.woodlandhills.hilton.com"          
    ## [299] "www1.hilton.com"                        "www3.hilton.com"