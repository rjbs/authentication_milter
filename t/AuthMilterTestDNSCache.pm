package AuthMilterTestDNSCache;
use strict;
use warnings;
use version; our $VERSION = version->declare('v1.1.0');

use base 'Net::DNS::Resolver';

use JSON;
use Data::Dumper;
use MIME::Base64;

## no critic [Subroutines::RequireArgUnpacking]

{

    sub new {
        my $class = shift;
        my %args = @_;
        my $self = $class->SUPER::new( @_ );

        $self->{'static_cache'} = {

            "query:99.123.123.123:PTR" => [ "", "NXDOMAIN" ],
            "query:123.123.123.123:PTR" => [ "", "NXDOMAIN" ],
            "query:1.2.3.4:PTR" => [ "", "NXDOMAIN" ],
            "query:74.125.82.171:PTR" => [ "dAOBgAABAAEAAAAAAzE3MQI4MgMxMjUCNzQHaW4tYWRkcgRhcnBhAAAMAAHADAAMAAEAAPI0ABoNbWFpbC13ZTAtZjE3MQZnb29nbGUDY29tAA==", "NOERROR" ] ,
            "query:example.com:A" => [ "Y2aBgAABAAEAAAAAB2V4YW1wbGUDY29tAAABAAHADAABAAEAAO3UAARduNgi", "NOERROR" ],
            "query:example.com:MX" => [ "", "NOERROR" ],
            "query:example.com:NS" => [ "Ao6BgAABAAIAAAACB2V4YW1wbGUDY29tAAACAAHADAACAAEAAIEAABQBYgxpYW5hLXNlcnZlcnMDbmV0AMAMAAIAAQAAgQAABAFhwCvAKQABAAEAAAbkAATHK4U1wEkAAQABAAAG5AAExyuENQ==", "NOERROR" ],
            "query:mail-we0-f171.google.com.:A" => [ "EZSBgAABAAEAAAAADW1haWwtd2UwLWYxNzEGZ29vZ2xlA2NvbQAAAQABwAwAAQABAADcPwAESn1Sqw==", "NOERROR" ] ,
            "query:marcbradshaw.net:MX" => [ "blWBgAABAAcAAAAHDG1hcmNicmFkc2hhdwNuZXQAAA8AAcAMAA8AAQAA8bsAGQAeBkFTUE1YMgpHT09HTEVNQUlMA0NPTQDADAAPAAEAAPG7AAsAHgZBU1BNWDXAN8AMAA8AAQAA8bsACwAeBkFTUE1YNMA3wAwADwABAADxuwAYABQEQUxUMgVBU1BNWAFMBkdPT0dMRcBCwAwADwABAADxuwAEAArAiMAMAA8AAQAA8bsACQAUBEFMVDHAiMAMAA8AAQAA8bsACwAeBkFTUE1YM8A3wDAAAQABAAAAeQAEQOmoGsBVAAEAAQAAAHwABEp9FhvAgwABAAEAAADvAARKfY4awLcAAQABAAAA7wAESn0ZGsDMAAEAAQAAALAABEp9jhvAbAABAAEAAAB8AARA6bkbwIgAAQABAAAA7wAESn3LGg==", "NOERROR" ] ,
            "query:marcbradshaw.net:NS" => [ "6VSBgAABAAcAAAAHDG1hcmNicmFkc2hhdwNuZXQAAAIAAcAMAAIAAQAA8bcAGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAADxtwAQA25zMwZsaW5vZGUDY29tAMAMAAIAAQAA8bcABgNuczLAWMAMAAIAAQAA8bcABgNuczTAWMAMAAIAAQAA8bcABgNuczbAMsAMAAIAAQAA8bcABgNuczHAWMAMAAIAAQAA8bcABgNuczXAWMCmAAEAAQABUV8ABEVdfwrAggABAAEAAVFfAATPwEYKwC4AAQABAADMhgAEarszxcBUAAEAAQABUV8ABEt/YArAuAABAAEAAVFfAARtSsIKwHAAAQABAAFRXwAEQROyCsCUAAEAAQAAzIYABLJPsGE=", "NOERROR" ] ,
            "send:99.123.123.123:PTR" => [ "dAOBgwABAAAAAQAAAzEyMwMxMjMDMTIzAzEyMwdpbi1hZGRyBGFycGEAAAwAAcAUAAYAAQAADhAAKgJucwNidGEDbmV0AmNuAARyb290wDp3oLggAABw4wAAHCAACTqAAAFRgA==", "NXDOMAIN" ] ,
            "send:123.123.123.123:PTR" => [ "dAOBgwABAAAAAQAAAzEyMwMxMjMDMTIzAzEyMwdpbi1hZGRyBGFycGEAAAwAAcAUAAYAAQAADhAAKgJucwNidGEDbmV0AmNuAARyb290wDp3oLggAABw4wAAHCAACTqAAAFRgA==", "NXDOMAIN" ] ,
            "send:1.2.3.4:PTR" => [ "doiBgwABAAAAAQAAATQBMwEyATEHaW4tYWRkcgRhcnBhAAAMAAHAEgAGAAEAAA27AE0DbnMxBWFwbmljA25ldAAncmVhZC10eHQtcmVjb3JkLW9mLXpvbmUtZmlyc3QtZG5zLWFkbWluwDYAABPuAAAcIAAABwgACTqAAAKjAA==", "NXDOMAIN" ] ,
            "send:20130820._domainkey.1e100.net:TXT" => [ "I8CBgAABAAEAAAAACDIwMTMwODIwCl9kb21haW5rZXkFMWUxMDADbmV0AAAQAAHADAAQAAEAAPICAZPJaz1yc2E7IHA9TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFuT3Y2K1R4eXorU0VjN21UNzE5UVF0T2o2ZzJNanBFcllVR1ZyUkdHYzdmNXJtRTFjUlAxbGh3eDhQVm9IT2l1Unp5b2s3SXFqdkF1YjlrazlmQm9FOXVYSkIxUWFSZE1uS3o3Vy9VaFdlbUs1VEVVZ1cxeFQ1cXRCZlVJcEZSTDM0aDZGYkhiZXlzYjRzemk3YVRnyGVyeEkxNW83M2NQNUJvUFZrUWo0QlFLa2ZUUVlHTkgwM0o1RGI5dU1xVy9OTko4ZktDTEtXTzVDMWUrTlExbEQ2dXdGQ2pKNlBXRm1BSWVVdTkrTGZZVzg5VHoxTm53dFNrRkM5Nk9reTFjbW5sQmY0ZGhaL1VwL0ZNWm1COWw3VEE2Z0xFdTZKaWpsRHJObXgxbzUwV0FEUGpqTjRyR0VMTHQzVnVYbjA5eTJwaUJQbFpQVTJTSWlEUUMwcVgwSldRSURBUUFC", "NOERROR" ] ,
            "send:74.125.82.171:PTR" => [ "dAOBgAABAAEAAAAAAzE3MQI4MgMxMjUCNzQHaW4tYWRkcgRhcnBhAAAMAAHADAAMAAEAAPI0ABoNbWFpbC13ZTAtZjE3MQZnb29nbGUDY29tAA==", "NOERROR" ] ,
            "send:_adsp._domainkey.marcbradshaw.net:TXT" => [ "eNuBgAABAAEAAAAABV9hZHNwCl9kb21haW5rZXkMbWFyY2JyYWRzaGF3A25ldAAAEAABwAwAEAABAADyAwANDGRraW09dW5rbm93bg==", "NOERROR" ] ,
            "send:_dmarc.example.com:TXT" => [ "kWiBgwABAAAAAQAABl9kbWFyYwdleGFtcGxlA2NvbQAAEAABwBMABgABAAAL3QAtA3NucwNkbnMFaWNhbm4Db3JnAANub2PANHgNDWwAABwgAAAOEAASdQAAAA4Q", "NXDOMAIN" ],
            "send:_dmarc.marcbradshaw.net:TXT" => [ "MvGBgAABAAEAAAAABl9kbWFyYwxtYXJjYnJhZHNoYXcDbmV0AAAQAAHADAAQAAEAAPHLAFdWdj1ETUFSQzE7IHA9bm9uZTsgcnVhPW1haWx0bzpkbWFyYy5yZXBvcnRzQG9wcy50d29maWZ0eWVpZ2h0Lmx0ZC51azsgcmY9YWZyZjsgcGN0PTEwMDs=", "NOERROR" ] ,
            "send:_domainkey.marcbradshaw.net:TXT" => [ "1BWBgAABAAAAAQAACl9kb21haW5rZXkMbWFyY2JyYWRzaGF3A25ldAAAEAABwBcABgABAAAOEABOA25zNQ10d29maWZ0eWVpZ2h0A2x0ZAJ1awAKaG9zdG1hc3Rlcg9lbGVjdHJpYy1kcmVhbXMDb3JnAHgMvm0AAHCAAAAcIAAk6gAAAVGA", "NOERROR" ] ,
            "send:example.com:A" => [ "Y2aBgAABAAEAAAAAB2V4YW1wbGUDY29tAAABAAHADAABAAEAAO3PAARduNgi", "NOERROR" ],
            "send:example.com:MX" => [ "BUyBgAABAAAAAQAAB2V4YW1wbGUDY29tAAAPAAHADAAGAAEAAAvdAC0Dc25zA2RucwVpY2FubgNvcmcAA25vY8AteA0NbAAAHCAAAA4QABJ1AAAADhA=", "NOERROR" ],
            "send:example.com:NS" => [ "Ao6BgAABAAIAAAACB2V4YW1wbGUDY29tAAACAAHADAACAAEAAIEAABQBYgxpYW5hLXNlcnZlcnMDbmV0AMAMAAIAAQAAgQAABAFhwCvAKQABAAEAAAbkAATHK4U1wEkAAQABAAAG5AAExyuENQ==", "NOERROR" ],
            "send:example.com:TXT" => [ "xluBgAABAAIAAAAAB2V4YW1wbGUDY29tAAAQAAHADAAQAAEAAAA3AAwLdj1zcGYxIC1hbGzADAAQAAEAAAA3ADU0JElkOiBleGFtcGxlLmNvbSAzMjgwIDIwMTQtMTItMTAgMDA6MTU6MTJaIHNwb3dlbGwgJA==", "NOERROR" ],
            "send:google._domainkey.marcbradshaw.net:TXT" => [ "doiBgAABAAEAAAAABmdvb2dsZQpfZG9tYWlua2V5DG1hcmNicmFkc2hhdwNuZXQAABAAAcAMABAAAQAA8hEA8O92PURLSU0xOyBrPXJzYTsgdD15OyBwPU1JR2ZNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0R05BRENCaVFLQmdRQzV6bDVTWGlsc0ZLZXZRR2lxQmxheUxlTCtiQnppNE45OFJqVi95aU0rdW56KzMxN2JXaFRVNjNiaVJ5SGJ2MERaNDMxdXFqOG1QVVJnbkxlZitTQk9Za0VEdi9kaGl6Y3FOVldIV0hKb3UvSS9vWHBqUFdKcVZJQnUyNDJ3eE5MSTNSOTJMaExHS2cwVy9KKytQb3NRdmxaM29nWWRtRE5ZK3dtUllGUEpsd0lEQVFBQg==", "NOERROR" ] ,
            "send:mail-we0-f171.google.com.:A" => [ "EZSBgAABAAEAAAAADW1haWwtd2UwLWYxNzEGZ29vZ2xlA2NvbQAAAQABwAwAAQABAADcPwAESn1Sqw==", "NOERROR" ] ,
            "send:marcbradshaw.net:MX" => [ "blWBgAABAAcAAAAHDG1hcmNicmFkc2hhdwNuZXQAAA8AAcAMAA8AAQAA8bsAGQAeBkFTUE1YMgpHT09HTEVNQUlMA0NPTQDADAAPAAEAAPG7AAsAHgZBU1BNWDXAN8AMAA8AAQAA8bsACwAeBkFTUE1YNMA3wAwADwABAADxuwAYABQEQUxUMgVBU1BNWAFMBkdPT0dMRcBCwAwADwABAADxuwAEAArAiMAMAA8AAQAA8bsACQAUBEFMVDHAiMAMAA8AAQAA8bsACwAeBkFTUE1YM8A3wDAAAQABAAAAeQAEQOmoGsBVAAEAAQAAAHwABEp9FhvAgwABAAEAAADvAARKfY4awLcAAQABAAAA7wAESn0ZGsDMAAEAAQAAALAABEp9jhvAbAABAAEAAAB8AARA6bkbwIgAAQABAAAA7wAESn3LGg==", "NOERROR" ] ,
            "send:marcbradshaw.net:NS" => [ "6VSBgAABAAcAAAAHDG1hcmNicmFkc2hhdwNuZXQAAAIAAcAMAAIAAQAA8bcAGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAADxtwAQA25zMwZsaW5vZGUDY29tAMAMAAIAAQAA8bcABgNuczLAWMAMAAIAAQAA8bcABgNuczTAWMAMAAIAAQAA8bcABgNuczbAMsAMAAIAAQAA8bcABgNuczHAWMAMAAIAAQAA8bcABgNuczXAWMCmAAEAAQABUV8ABEVdfwrAggABAAEAAVFfAATPwEYKwC4AAQABAADMhgAEarszxcBUAAEAAQABUV8ABEt/YArAuAABAAEAAVFfAARtSsIKwHAAAQABAAFRXwAEQROyCsCUAAEAAQAAzIYABLJPsGE=", "NOERROR" ] ,
            "send:marcbradshaw.net:TXT" => [ "9WyBgAABAAEAAAAADG1hcmNicmFkc2hhdwNuZXQAABAAAcAMABAAAQAA8ewA1tV2PXNwZjEgaW5jbHVkZTpzcGYubWFuZHJpbGxhcHAuY29tIGluY2x1ZGU6X3NwZi5nb29nbGUuY29tIGlwNDoxNzguNzkuMTc2Ljk3IGlwNjoyYTAxOjdlMDA6OmYwM2M6OTFmZjpmZTkzOjFjZCBpcDQ6MTA2LjE4Ny41MS4xOTcgaXA2OjI0MDA6ODkwMDo6ZjAzYzo5MWZmOmZlNmU6ODRjNyBpcDQ6NTkuMTY3LjE5OC4xNTMgaXA2OjIwMDE6NDRiODo2MjpjMDo6LzY0IH5hbGw=", "NOERROR" ] ,
            "send:_netblocks2.google.com:TXT" => [ "9fyBgAABAAEAAAAAC19uZXRibG9ja3MyBmdvb2dsZQNjb20AABAAAcAMABAAAQAAC9EAm5p2PXNwZjEgaXA2OjIwMDE6NDg2MDo0MDAwOjovMzYgaXA2OjI0MDQ6NjgwMDo0MDAwOjovMzYgaXA2OjI2MDc6ZjhiMDo0MDAwOjovMzYgaXA2OjI4MDA6M2YwOjQwMDA6Oi8zNiBpcDY6MmEwMDoxNDUwOjQwMDA6Oi8zNiBpcDY6MmMwZjpmYjUwOjQwMDA6Oi8zNiB+YWxs", "NOERROR" ],
            "send:_netblocks3.google.com:TXT" => [ "BXKBgAABAAEAAAAAC19uZXRibG9ja3MzBmdvb2dsZQNjb20AABAAAcAMABAAAQAAC1IADAt2PXNwZjEgfmFsbA==", "NOERROR" ],
            "send:_netblocks.google.com:TXT" => [ "3iGBgAABAAEAAAAACl9uZXRibG9ja3MGZ29vZ2xlA2NvbQAAEAABwAwAEAABAAAFjwDf3nY9c3BmMSBpcDQ6NjQuMTguMC4wLzIwIGlwNDo2NC4yMzMuMTYwLjAvMTkgaXA0OjY2LjEwMi4wLjAvMjAgaXA0OjY2LjI0OS44MC4wLzIwIGlwNDo3Mi4xNC4xOTIuMC8xOCBpcDQ6NzQuMTI1LjAuMC8xNiBpcDQ6MTczLjE5NC4wLjAvMTYgaXA0OjIwNy4xMjYuMTQ0LjAvMjAgaXA0OjIwOS44NS4xMjguMC8xNyBpcDQ6MjE2LjU4LjIwOC4wLzIwIGlwNDoyMTYuMjM5LjMyLjAvMTkgfmFsbA==", "NOERROR" ] ,
            "send:_policy._domainkey.marcbradshaw.net:TXT" => [ "luaBgwABAAAAAQAAB19wb2xpY3kKX2RvbWFpbmtleQxtYXJjYnJhZHNoYXcDbmV0AAAQAAHAHwAGAAEAAA4QAE4DbnM1DXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAApob3N0bWFzdGVyD2VsZWN0cmljLWRyZWFtcwNvcmcAeAy+bQAAcIAAABwgACTqAAABUYA=", "NXDOMAIN" ] ,
            "send:_spf.google.com:TXT" => [ "aoWBgAABAAEAAAAABF9zcGYGZ29vZ2xlA2NvbQAAEAABwAwAEAABAAAA8gBoZ3Y9c3BmMSBpbmNsdWRlOl9uZXRibG9ja3MuZ29vZ2xlLmNvbSBpbmNsdWRlOl9uZXRibG9ja3MyLmdvb2dsZS5jb20gaW5jbHVkZTpfbmV0YmxvY2tzMy5nb29nbGUuY29tIH5hbGw=", "NOERROR" ] ,
            "send:spf.mandrillapp.com:TXT" => [ "ItSBgAABAAEAAAAAA3NwZgttYW5kcmlsbGFwcANjb20AABAAAcAMABAAAQAAeVMAiol2PXNwZjEgaXA0OjE5OC4yLjEyOC4wLzI0IGlwNDoxOTguMi4xMzIuMC8yMiBpcDQ6MjA1LjIwMS4xMzEuMTI4LzI1IGlwNDoyMDUuMjAxLjEzNC4xMjgvMjUgaXA0OjIwNS4yMDEuMTM2LjAvMjMgaXA0OjIwNS4yMDEuMTM5LjAvMjQgP2FsbA==", "NOERROR" ],
            'send:goestheweasel.com:A' => [ 'qa+BgAABAAIABwANDWdvZXN0aGV3ZWFzZWwDY29tAAABAAHADAABAAEAAA1AAARquzPFwAwAAQABAAANQAAE1Ef3E8AMAAIAAQAAAU4AGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAAABTgANA25zNAZsaW5vZGXAGsAMAAIAAQAAAU4ABgNuczXAecAMAAIAAQAAAU4ABgNuczfAU8AMAAIAAQAAAU4ABgNuczPAecAMAAIAAQAAAU4ABgNuczLAecAMAAIAAQAAAU4ABgNuczHAecDWAAEAAQABTCsABKKfG0jA1gAcAAEAATxBABAkAMsAIEkAAQAAAACinxpjwMQAAQABAAFMKwAEop8YJ8DEABwAAQABPEEAECQAywAgSQABAAAAAKKfGCfAsgABAAEAAUwrAASinxmBwLIAHAABAAE8QQAQJADLACBJAAEAAAAAop8ZgcB1AAEAAQABTCsABKKfGmPAdQAcAAEAATxBABAkAMsAIEkAAQAAAACinxtIwI4AAQABAAFMKwAEop8YGcCOABwAAQABPEEAECQAywAgSQABAAAAAKKfGBnATwABAAEAAot0AARquzPFwE8AHAABAAKLdAAQJACJAAAAAADwPJH//m6Ex8CgAAEAAQACi3QABNRH9xM=', 'NOERROR'],
            'send:goestheweasel.com:AAAA' => ['m6OBgAABAAIABwAMDWdvZXN0aGV3ZWFzZWwDY29tAAAcAAHADAAcAAEAAA1BABAkAIkAAAAAAPA8kf/+boTHwAwAHAABAAANQQAQKgF+AAAAAADwPJH//jNlxsAMAAIAAQAAAU4ADQNuczEGbGlub2RlwBrADAACAAEAAAFOABoDbnM3DXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAMAMAAIAAQAAAU4ABgNuczTAa8AMAAIAAQAAAU4ABgNuczPAa8AMAAIAAQAAAU4ABgNuczLAa8AMAAIAAQAAAU4ABgNuczXAhMAMAAIAAQAAAU4ABgNuczXAa8BnAAEAAQABTCsABKKfG0jAZwAcAAEAATxBABAkAMsAIEkAAQAAAACinxpjwMoAAQABAAFMKwAEop8YJ8DKABwAAQABPEEAECQAywAgSQABAAAAAKKfGCfAuAABAAEAAUwrAASinxmBwLgAHAABAAE8QQAQJADLACBJAAEAAAAAop8ZgcCmAAEAAQABTCsABKKfGmPApgAcAAEAATxBABAkAMsAIEkAAQAAAACinxtIwO4AAQABAAFMKwAEop8YGcDuABwAAQABPEEAECQAywAgSQABAAAAAKKfGBnA3AABAAEAAot0AARquzPFwNwAHAABAAKLdAAQJACJAAAAAADwPJH//m6Exw==','NOERROR'],
            'send:_dmarc.goestheweasel.com:TXT' => ['o8uBgAABAAEABwAJBl9kbWFyYw1nb2VzdGhld2Vhc2VsA2NvbQAAEAABwAwAEAABAAABTgBZWHY9RE1BUkMxOyBwPXJlamVjdDsgcnVhPW1haWx0bzpkbWFyYy5yZXBvcnRzQG9wcy50d29maWZ0eWVpZ2h0Lmx0ZC51azsgcmY9YWZyZjsgcGN0PTEwMDvAEwACAAEAAAFOAA0DbnM1Bmxpbm9kZcAhwBMAAgABAAABTgAGA25zNMCfwBMAAgABAAABTgAGA25zM8CfwBMAAgABAAABTgAaA25zNQ10d29maWZ0eWVpZ2h0A2x0ZAJ1awDAEwACAAEAAAFOAAYDbnMywJ/AEwACAAEAAAFOAAYDbnMxwJ/AEwACAAEAAAFOAAYDbnM3wNzBEAABAAEAAUwrAASinxtIwRAAHAABAAE8QQAQJADLACBJAAEAAAAAop8aY8D+AAEAAQABTCsABKKfGCfA/gAcAAEAATxBABAkAMsAIEkAAQAAAACinxgnwMYAAQABAAFMKwAEop8ZgcDGABwAAQABPEEAECQAywAgSQABAAAAAKKfGYHAtAABAAEAAUwrAASinxpjwLQAHAABAAE8QQAQJADLACBJAAEAAAAAop8bSMCbAAEAAQABTCsABKKfGBk=','NOERROR'],
            'query:goestheweasel.com:MX' => ['M2CBgAABAAQABwAKDWdvZXN0aGV3ZWFzZWwDY29tAAAPAAHADAAPAAEAAA1BABwACgNteDUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwADwABAAANQQAIAAoDbXg2wDXADAAPAAEAAA1BABsAHgNteDUPZWxlY3RyaWMtZHJlYW1zA29yZwDADAAPAAEAAA1BAAgAHgNteDbAccAMAAIAAQAAAU4ABgNuczfANcAMAAIAAQAAAU4ADQNuczIGbGlub2RlwBrADAACAAEAAAFOAAYDbnMzwLzADAACAAEAAAFOAAYDbnM1wDXADAACAAEAAAFOAAYDbnM1wLzADAACAAEAAAFOAAYDbnM0wLzADAACAAEAAAFOAAYDbnMxwLzAMQABAAEAAAdVAARquzPFwRkAAQABAAFMKwAEop8bSMEZABwAAQABPEEAECQAywAgSQABAAAAAKKfGmPAuAABAAEAAUwrAASinxgnwLgAHAABAAE8QQAQJADLACBJAAEAAAAAop8YJ8DRAAEAAQABTCsABKKfGYHA0QAcAAEAATxBABAkAMsAIEkAAQAAAACinxmBwQcAAQABAAFMKwAEop8aY8EHABwAAQABPEEAECQAywAgSQABAAAAAKKfG0jA9QABAAEAAUwrAASinxgZ','NOERROR'],
            'query:goestheweasel.com:A' => ['qa+BgAABAAIABwANDWdvZXN0aGV3ZWFzZWwDY29tAAABAAHADAABAAEAAA1AAARquzPFwAwAAQABAAANQAAE1Ef3E8AMAAIAAQAAAU4AGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAAABTgANA25zNAZsaW5vZGXAGsAMAAIAAQAAAU4ABgNuczXAecAMAAIAAQAAAU4ABgNuczfAU8AMAAIAAQAAAU4ABgNuczPAecAMAAIAAQAAAU4ABgNuczLAecAMAAIAAQAAAU4ABgNuczHAecDWAAEAAQABTCsABKKfG0jA1gAcAAEAATxBABAkAMsAIEkAAQAAAACinxpjwMQAAQABAAFMKwAEop8YJ8DEABwAAQABPEEAECQAywAgSQABAAAAAKKfGCfAsgABAAEAAUwrAASinxmBwLIAHAABAAE8QQAQJADLACBJAAEAAAAAop8ZgcB1AAEAAQABTCsABKKfGmPAdQAcAAEAATxBABAkAMsAIEkAAQAAAACinxtIwI4AAQABAAFMKwAEop8YGcCOABwAAQABPEEAECQAywAgSQABAAAAAKKfGBnATwABAAEAAot0AARquzPFwE8AHAABAAKLdAAQJACJAAAAAADwPJH//m6Ex8CgAAEAAQACi3QABNRH9xM=','NOERROR'],
            'query:_dmarc.goestheweasel.com:TXT' => ['o8uBgAABAAEABwAJBl9kbWFyYw1nb2VzdGhld2Vhc2VsA2NvbQAAEAABwAwAEAABAAABTgBZWHY9RE1BUkMxOyBwPXJlamVjdDsgcnVhPW1haWx0bzpkbWFyYy5yZXBvcnRzQG9wcy50d29maWZ0eWVpZ2h0Lmx0ZC51azsgcmY9YWZyZjsgcGN0PTEwMDvAEwACAAEAAAFOAA0DbnM1Bmxpbm9kZcAhwBMAAgABAAABTgAGA25zNMCfwBMAAgABAAABTgAGA25zM8CfwBMAAgABAAABTgAaA25zNQ10d29maWZ0eWVpZ2h0A2x0ZAJ1awDAEwACAAEAAAFOAAYDbnMywJ/AEwACAAEAAAFOAAYDbnMxwJ/AEwACAAEAAAFOAAYDbnM3wNzBEAABAAEAAUwrAASinxtIwRAAHAABAAE8QQAQJADLACBJAAEAAAAAop8aY8D+AAEAAQABTCsABKKfGCfA/gAcAAEAATxBABAkAMsAIEkAAQAAAACinxgnwMYAAQABAAFMKwAEop8ZgcDGABwAAQABPEEAECQAywAgSQABAAAAAKKfGYHAtAABAAEAAUwrAASinxpjwLQAHAABAAE8QQAQJADLACBJAAEAAAAAop8bSMCbAAEAAQABTCsABKKfGBk=','NOERROR'],
            'query:goestheweasel.com:AAAA' => ['m6OBgAABAAIABwAMDWdvZXN0aGV3ZWFzZWwDY29tAAAcAAHADAAcAAEAAA1BABAkAIkAAAAAAPA8kf/+boTHwAwAHAABAAANQQAQKgF+AAAAAADwPJH//jNlxsAMAAIAAQAAAU4ADQNuczEGbGlub2RlwBrADAACAAEAAAFOABoDbnM3DXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAMAMAAIAAQAAAU4ABgNuczTAa8AMAAIAAQAAAU4ABgNuczPAa8AMAAIAAQAAAU4ABgNuczLAa8AMAAIAAQAAAU4ABgNuczXAhMAMAAIAAQAAAU4ABgNuczXAa8BnAAEAAQABTCsABKKfG0jAZwAcAAEAATxBABAkAMsAIEkAAQAAAACinxpjwMoAAQABAAFMKwAEop8YJ8DKABwAAQABPEEAECQAywAgSQABAAAAAKKfGCfAuAABAAEAAUwrAASinxmBwLgAHAABAAE8QQAQJADLACBJAAEAAAAAop8ZgcCmAAEAAQABTCsABKKfGmPApgAcAAEAATxBABAkAMsAIEkAAQAAAACinxtIwO4AAQABAAFMKwAEop8YGcDuABwAAQABPEEAECQAywAgSQABAAAAAKKfGBnA3AABAAEAAot0AARquzPFwNwAHAABAAKLdAAQJACJAAAAAADwPJH//m6Exw==','NOERROR'],
            'send:goestheweasel.com:MX' => ['M2CBgAABAAQABwAKDWdvZXN0aGV3ZWFzZWwDY29tAAAPAAHADAAPAAEAAA1BABwACgNteDUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwADwABAAANQQAIAAoDbXg2wDXADAAPAAEAAA1BABsAHgNteDUPZWxlY3RyaWMtZHJlYW1zA29yZwDADAAPAAEAAA1BAAgAHgNteDbAccAMAAIAAQAAAU4ABgNuczfANcAMAAIAAQAAAU4ADQNuczIGbGlub2RlwBrADAACAAEAAAFOAAYDbnMzwLzADAACAAEAAAFOAAYDbnM1wDXADAACAAEAAAFOAAYDbnM1wLzADAACAAEAAAFOAAYDbnM0wLzADAACAAEAAAFOAAYDbnMxwLzAMQABAAEAAAdVAARquzPFwRkAAQABAAFMKwAEop8bSMEZABwAAQABPEEAECQAywAgSQABAAAAAKKfGmPAuAABAAEAAUwrAASinxgnwLgAHAABAAE8QQAQJADLACBJAAEAAAAAop8YJ8DRAAEAAQABTCsABKKfGYHA0QAcAAEAATxBABAkAMsAIEkAAQAAAACinxmBwQcAAQABAAFMKwAEop8aY8EHABwAAQABPEEAECQAywAgSQABAAAAAKKfG0jA9QABAAEAAUwrAASinxgZ','NOERROR'],
            'query:goestheweasel.com:TXT' => ['lh2BgAABAAIABwADDWdvZXN0aGV3ZWFzZWwDY29tAAAQAAHADAAQAAEAAA4QAEVEZ29vZ2xlLXNpdGUtdmVyaWZpY2F0aW9uPWQxRXBlZ2hIczFjc214WE9McHlQV0RTUEg4NUlYdWRmVFhoUmNoNk8xTHfADAAQAAEAAA4QAKOidj1zcGYxIGlwNDoyMTIuNzEuMjQ3LjE5IGlwNjoyYTAxOjdlMDA6OmYwM2M6OTFmZjpmZTMzOjY1YzYgaXA0OjEwNi4xODcuNTEuMTk3IGlwNjoyNDAwOjg5MDA6OmYwM2M6OTFmZjpmZTZlOjg0YzcgaXA0OjU5LjE2Ny4xOTguMTUzIGlwNjoyMDAxOjQ0Yjg6NjI6YzA6Oi82NCAtYWxswAwAAgABAAANBwANA25zNQZsaW5vZGXAGsAMAAIAAQAADQcABgNuczPBM8AMAAIAAQAADQcABgNuczHBM8AMAAIAAQAADQcABgNuczLBM8AMAAIAAQAADQcAGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAAANBwAGA25zN8GCwAwAAgABAAANBwAGA25zNMEzwVoAAQABAAFE1AAEop8bSMFaABwAAQABNOoAECQAywAgSQABAAAAAKKfGmPBbAABAAEAAUTUAASinxgn','NOERROR'],
            'send:goestheweasel.com:TXT' => ['lh2BgAABAAIABwADDWdvZXN0aGV3ZWFzZWwDY29tAAAQAAHADAAQAAEAAA4QAEVEZ29vZ2xlLXNpdGUtdmVyaWZpY2F0aW9uPWQxRXBlZ2hIczFjc214WE9McHlQV0RTUEg4NUlYdWRmVFhoUmNoNk8xTHfADAAQAAEAAA4QAKOidj1zcGYxIGlwNDoyMTIuNzEuMjQ3LjE5IGlwNjoyYTAxOjdlMDA6OmYwM2M6OTFmZjpmZTMzOjY1YzYgaXA0OjEwNi4xODcuNTEuMTk3IGlwNjoyNDAwOjg5MDA6OmYwM2M6OTFmZjpmZTZlOjg0YzcgaXA0OjU5LjE2Ny4xOTguMTUzIGlwNjoyMDAxOjQ0Yjg6NjI6YzA6Oi82NCAtYWxswAwAAgABAAANBwANA25zNQZsaW5vZGXAGsAMAAIAAQAADQcABgNuczPBM8AMAAIAAQAADQcABgNuczHBM8AMAAIAAQAADQcABgNuczLBM8AMAAIAAQAADQcAGgNuczUNdHdvZmlmdHllaWdodANsdGQCdWsAwAwAAgABAAANBwAGA25zN8GCwAwAAgABAAANBwAGA25zNMEzwVoAAQABAAFE1AAEop8bSMFaABwAAQABNOoAECQAywAgSQABAAAAAKKfGmPBbAABAAEAAUTUAASinxgn','NOERROR' ],
            'send:goestheweasel.com:NS' => ['sUCBgAABAAcAAAAODWdvZXN0aGV3ZWFzZWwDY29tAAACAAHADAACAAEAAAuNABoDbnM1DXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAMAMAAIAAQAAC40ADQNuczEGbGlub2RlwBrADAACAAEAAAuNAAYDbnM3wDPADAACAAEAAAuNAAYDbnMywFnADAACAAEAAAuNAAYDbnM0wFnADAACAAEAAAuNAAYDbnM1wFnADAACAAEAAAuNAAYDbnMzwFnAVQABAAEAAUNaAASinxtIwFUAHAABAAEzcAAQJADLACBJAAEAAAAAop8aY8CAAAEAAQABQ1oABKKfGCfAgAAcAAEAATNwABAkAMsAIEkAAQAAAACinxgnwLYAAQABAAFDWgAEop8ZgcC2ABwAAQABM3AAECQAywAgSQABAAAAAKKfGYHAkgABAAEAAUNaAASinxpjwJIAHAABAAEzcAAQJADLACBJAAEAAAAAop8bSMCkAAEAAQABQ1oABKKfGBnApAAcAAEAATNwABAkAMsAIEkAAQAAAACinxgZwC8AAQABAAKCowAEarszxcAvABwAAQACgqMAECQAiQAAAAAA8DyR//5uhMfAbgABAAEAAoKjAATUR/cTwG4AHAABAAKCowAQKgF+AAAAAADwPJH//jNlxg==','NOERROR'],
            'query:goestheweasel.com:NS' => ['sUCBgAABAAcAAAAODWdvZXN0aGV3ZWFzZWwDY29tAAACAAHADAACAAEAAAuNABoDbnM1DXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAMAMAAIAAQAAC40ADQNuczEGbGlub2RlwBrADAACAAEAAAuNAAYDbnM3wDPADAACAAEAAAuNAAYDbnMywFnADAACAAEAAAuNAAYDbnM0wFnADAACAAEAAAuNAAYDbnM1wFnADAACAAEAAAuNAAYDbnMzwFnAVQABAAEAAUNaAASinxtIwFUAHAABAAEzcAAQJADLACBJAAEAAAAAop8aY8CAAAEAAQABQ1oABKKfGCfAgAAcAAEAATNwABAkAMsAIEkAAQAAAACinxgnwLYAAQABAAFDWgAEop8ZgcC2ABwAAQABM3AAECQAywAgSQABAAAAAKKfGYHAkgABAAEAAUNaAASinxpjwJIAHAABAAEzcAAQJADLACBJAAEAAAAAop8bSMCkAAEAAQABQ1oABKKfGBnApAAcAAEAATNwABAkAMsAIEkAAQAAAACinxgZwC8AAQABAAKCowAEarszxcAvABwAAQACgqMAECQAiQAAAAAA8DyR//5uhMfAbgABAAEAAoKjAATUR/cTwG4AHAABAAKCowAQKgF+AAAAAADwPJH//jNlxg==','NOERROR'],
            'query:marcbradshaw.net._report._dmarc.ops.twofiftyeight.ltd.uk:TXT' => ['0QaBgAABAAEABwANDG1hcmNicmFkc2hhdwNuZXQHX3JlcG9ydAZfZG1hcmMDb3BzDXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAAAQAAHADAAQAAEAAA4QAAkIdj1ETUFSQzHAMAACAAEAAAUcABADbnM1Bmxpbm9kZQNjb20AwDAAAgABAAAFHAAGA25zMcBvwDAAAgABAAAFHAAGA25zNcAwwDAAAgABAAAFHAAGA25zN8AwwDAAAgABAAAFHAAGA25zNMBvwDAAAgABAAAFHAAGA25zM8BvwDAAAgABAAAFHAAGA25zMsBvwIcAAQABAAEiLgAEop8bSMCHABwAAQABHLYAECQAywAgSQABAAAAAKKfGmPA4QABAAEAASA+AASinxgnwOEAHAABAAEctgAQJADLACBJAAEAAAAAop8YJ8DPAAEAAQABID4ABKKfGYHAzwAcAAEAARy2ABAkAMsAIEkAAQAAAACinxmBwL0AAQABAAEgPgAEop8aY8C9ABwAAQABHLYAECQAywAgSQABAAAAAKKfG0jAawABAAEAASA+AASinxgZwGsAHAABAAEctgAQJADLACBJAAEAAAAAop8YGcCZAAEAAQACZTUABGq7M8XAmQAcAAEAAmU1ABAkAIkAAAAAAPA8kf/+boTHwKsAAQABAAJlNQAE1Ef3Ew==',''],
            'query:goestheweasel.com._report._dmarc.ops.twofiftyeight.ltd.uk:TXT' => ['WjmBgAABAAEABwANDWdvZXN0aGV3ZWFzZWwDY29tB19yZXBvcnQGX2RtYXJjA29wcw10d29maWZ0eWVpZ2h0A2x0ZAJ1awAAEAABwAwAEAABAAAN8gAJCHY9RE1BUkMxwDEAAgABAAADUgAGA25zN8AxwDEAAgABAAADUgAQA25zNQZsaW5vZGUDY29tAMAxAAIAAQAAA1IABgNuczTAgsAxAAIAAQAAA1IABgNuczLAgsAxAAIAAQAAA1IABgNuczHAgsAxAAIAAQAAA1IABgNuczPAgsAxAAIAAQAAA1IABgNuczXAMcC+AAEAAQABIGQABKKfG0jAvgAcAAEAARrsABAkAMsAIEkAAQAAAACinxpjwKwAAQABAAEedAAEop8YJ8CsABwAAQABGuwAECQAywAgSQABAAAAAKKfGCfA0AABAAEAAR50AASinxmBwNAAHAABAAEa7AAQJADLACBJAAEAAAAAop8ZgcCaAAEAAQABHnQABKKfGmPAmgAcAAEAARrsABAkAMsAIEkAAQAAAACinxtIwH4AAQABAAEedAAEop8YGcB+ABwAAQABGuwAECQAywAgSQABAAAAAKKfGBnA4gABAAEAAmNrAARquzPFwOIAHAABAAJjawAQJACJAAAAAADwPJH//m6Ex8BsAAEAAQACY2sABNRH9xM=',''],
            'send:goestheweasel.com._report._dmarc.ops.twofiftyeight.ltd.uk:TXT' => ['WjmBgAABAAEABwANDWdvZXN0aGV3ZWFzZWwDY29tB19yZXBvcnQGX2RtYXJjA29wcw10d29maWZ0eWVpZ2h0A2x0ZAJ1awAAEAABwAwAEAABAAAN8gAJCHY9RE1BUkMxwDEAAgABAAADUgAGA25zN8AxwDEAAgABAAADUgAQA25zNQZsaW5vZGUDY29tAMAxAAIAAQAAA1IABgNuczTAgsAxAAIAAQAAA1IABgNuczLAgsAxAAIAAQAAA1IABgNuczHAgsAxAAIAAQAAA1IABgNuczPAgsAxAAIAAQAAA1IABgNuczXAMcC+AAEAAQABIGQABKKfG0jAvgAcAAEAARrsABAkAMsAIEkAAQAAAACinxpjwKwAAQABAAEedAAEop8YJ8CsABwAAQABGuwAECQAywAgSQABAAAAAKKfGCfA0AABAAEAAR50AASinxmBwNAAHAABAAEa7AAQJADLACBJAAEAAAAAop8ZgcCaAAEAAQABHnQABKKfGmPAmgAcAAEAARrsABAkAMsAIEkAAQAAAACinxtIwH4AAQABAAEedAAEop8YGcB+ABwAAQABGuwAECQAywAgSQABAAAAAKKfGBnA4gABAAEAAmNrAARquzPFwOIAHAABAAJjawAQJACJAAAAAADwPJH//m6Ex8BsAAEAAQACY2sABNRH9xM=',''],
            'send:marcbradshaw.net._report._dmarc.ops.twofiftyeight.ltd.uk:TXT' => ['D+CBgAABAAEABwANDG1hcmNicmFkc2hhdwNuZXQHX3JlcG9ydAZfZG1hcmMDb3BzDXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAAAQAAHADAAQAAEAAAw0AAkIdj1ETUFSQzHAMAACAAEAAANAABADbnM0Bmxpbm9kZQNjb20AwDAAAgABAAADQAAGA25zM8BvwDAAAgABAAADQAAGA25zNcAwwDAAAgABAAADQAAGA25zNcBvwDAAAgABAAADQAAGA25zMsBvwDAAAgABAAADQAAGA25zN8AwwDAAAgABAAADQAAGA25zMcBvwOEAAQABAAEgUgAEop8bSMDhABwAAQABGtoAECQAywAgSQABAAAAAKKfGmPAvQABAAEAAR5iAASinxgnwL0AHAABAAEa2gAQJADLACBJAAEAAAAAop8YJ8CHAAEAAQABHmIABKKfGYHAhwAcAAEAARraABAkAMsAIEkAAQAAAACinxmBwGsAAQABAAEeYgAEop8aY8BrABwAAQABGtoAECQAywAgSQABAAAAAKKfG0jAqwABAAEAAR5iAASinxgZwKsAHAABAAEa2gAQJADLACBJAAEAAAAAop8YGcCZAAEAAQACY1kABGq7M8XAmQAcAAEAAmNZABAkAIkAAAAAAPA8kf/+boTHwM8AAQABAAJjWQAE1Ef3Ew==',''],
            'query:marcbradshaw.net._report._dmarc.ops.twofiftyeight.ltd.uk:TXT' => ['D+CBgAABAAEABwANDG1hcmNicmFkc2hhdwNuZXQHX3JlcG9ydAZfZG1hcmMDb3BzDXR3b2ZpZnR5ZWlnaHQDbHRkAnVrAAAQAAHADAAQAAEAAAw0AAkIdj1ETUFSQzHAMAACAAEAAANAABADbnM0Bmxpbm9kZQNjb20AwDAAAgABAAADQAAGA25zM8BvwDAAAgABAAADQAAGA25zNcAwwDAAAgABAAADQAAGA25zNcBvwDAAAgABAAADQAAGA25zMsBvwDAAAgABAAADQAAGA25zN8AwwDAAAgABAAADQAAGA25zMcBvwOEAAQABAAEgUgAEop8bSMDhABwAAQABGtoAECQAywAgSQABAAAAAKKfGmPAvQABAAEAAR5iAASinxgnwL0AHAABAAEa2gAQJADLACBJAAEAAAAAop8YJ8CHAAEAAQABHmIABKKfGYHAhwAcAAEAARraABAkAMsAIEkAAQAAAACinxmBwGsAAQABAAEeYgAEop8aY8BrABwAAQABGtoAECQAywAgSQABAAAAAKKfG0jAqwABAAEAAR5iAASinxgZwKsAHAABAAEa2gAQJADLACBJAAEAAAAAop8YGcCZAAEAAQACY1kABGq7M8XAmQAcAAEAAmNZABAkAIkAAAAAAPA8kf/+boTHwM8AAQABAAJjWQAE1Ef3Ew==',''],

        };
        return $self;
    }
}

sub send { ## no critic
    my ( $self ) = shift;
    my @args = @_;
    return $self->cache_lookup( 'send', @args );
}

sub query {
    my ( $self ) = shift;
    my @args = @_;
    return $self->cache_lookup( 'query', @args );
}

sub search {
    my ( $self ) = shift;
    my @args = @_;
    return $self->cache_lookup( 'search', @args );
}

sub cache_lookup {
    my $self = shift;
    my $type = shift;
    my @args = @_;
    my $key = join(":" , $type, @args);
    my $static_cache  = $self->{'static_cache'};

    warn "FAKE DNS Lookup $key";

    my $return;

    if ( exists ( $static_cache->{$key} ) ) {
        my $packet = $static_cache->{$key}->[0];
        my $error  = $static_cache->{$key}->[1];
        my $data   = decode_base64( $packet );
        my $return_packet = Net::DNS::Packet->new( \$data );
        $self->errorstring( $error );

        return $return_packet;
    }

    warn "LOOKUP FAILED";
    die;
    return;
}

1;

