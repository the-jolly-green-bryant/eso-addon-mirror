-- Custom Badges for the "Siyah Atlı Kurye" Guild (PC/EU)
-- Made by @CradonWar for @sirinsidiator's addon "Aetherius Badge Filter" - http://www.esoui.com/downloads/info1354-AetheriusBadgeFilter.html
-- Thanks a lot for all the help and for this awesome addon, @sirinsidiator!
-- Last edited: 12/09/2018
AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Siyah Atlı Kurye", {
    {
        name = "|cFDFFBFBilgi (Önizleme)|r",
        description = "Siyah Atlı Kurye'nin Aetherius Badge Filter listesine hoş geldiniz!\n\n|cFDFFBFRozet Nedir?|r\nRozetler kısacası bir lonca üyesinin notlarına yerleştirilen renk formatlı etiketlerdir. Örneğin |cFF0000Rozetim|r bir rozettir. Rütbelerin aksine, herhangi bir sınırlaması olmadığı için rozetler daha değişken ve çeşitli olabilmektedir. Herhangi bir yetkiliden notunuza eklemesini isteyebileceğiniz bazı rütbesiz rozetler var. Fakat lonca rütbenizi geliştirip yükseltmek için Rütbe Rozetine ihtiyacınız var.\n\n|cFDFFBFRütbe Rozeti Nedir?|r\nRütbe Rozeti lonca içerisinde rütbenizin yükselmesini sağlayan ilerlemenizi belirler. Örneğin: loncaya sadık kalmak, Lonca Etkinliklerine katılmak, Lonca Mağazasında (Lonca Tüccarı varken) eşya satmak, Lonca Bankasına altın bağışlamak, vs.",
        badges = {
        },
    },
    {
        name = "|cFDFFBFLonca Rütbeleri (Önizleme)|r",
        description = "|cFDFFBF[Efsane]|r\nBu rütbe için 200 rütbeli rozet kazanın.\n\n|cFDFFBF[Usta]|r\nBu rütbe için 100 rütbeli rozet kazanın.\n\n|cFDFFBF[Kıdemli]|r\nBu rütbe için 50 rütbeli rozet kazanın.\n\n|cFDFFBF[Deneyimli]|r\nBu rütbe için 25 rütbeli rozet kazanın.\n\n|cFDFFBF[Üye]|r\nBu rütbe için 5 rütbeli rozet kazanın.\n\n|cFDFFBF[Acemi]|r\nSiyah Atlı Kurye'ye hoş geldiniz!",
        badges = {
        },
    },
    {
        name = "Yönetim",
        description = "Herhangi bir soru, öneri, şikayet vb. için iletişim kurabileceğiniz yetkili kişiler.",
        badges = {
            {
                name = "Kurucu",
                description = "Siyah Atlı Kurye'deki İlk Kurye(ler).",
                color = "FFD700",
            },
            {
                name = "Yetkili",
                description = "Siyah Atlı Kurye'nin aktif yetkilisi.",
                color = "FF0000",
            },
            {
                name = "Reklamcı",
                description = "Siyah Atlı Kurye'nin aktif reklamcısı.",
                color = "FF0000",
            },
            {
                name = "PVE Organizatörü",
                description = "Trial veya grup zindanları için Etkinlik Organizatörü.",
                color = "FF0000",
            },
            {
                name = "PVP Organizatörü",
                description = "AvA, Battleground veya düellolar için Etkinlik Organizatörü.",
                color = "FF0000",
            },
            {
                name = "Topluluk Organizatörü",
                description = "Sosyal lonca etkinlikleri için Etkinlik Organizatörü.",
                color = "FF0000",
            },
        }
    },
    {
        name = "Sadakat Rozetleri",
        description = "Üyelere loncaya olan sadakatleri için verilen rozetlerdir. Bu rozetler lonca içerisinde rütbenizin yükselmesi için esas alınır.",
        badges = {
            {
                name = "VIP",
                description = "Kuruşuştan beri loncada olan ya da loncaya veya topluluğa özel bir katkısı bulunan tanınmış üyelerdir. Farklı kurallar uygulanır. Bu rozeti yalnızca kurucular tarafından alabilirsiniz.\n\n|cFDFFBFNOT: Bu üyeler loncadan kovulmayabilirler!|r",
                color = "FFD700",
            },
            {
                name = "Antik",
                description = "Bir yıldan uzun süredir lonca üyesi.\n4 adet rozet olarak sayılır.",
                color = "A19CDE",
            },
            {
                name = "Eski",
                description = "200 günden uzun süredir lonca üyesi.\n3 adet rozet olarak sayılır.",
                color = "A19CDE",
            },
            {
                name = "Emektar",
                description = "100 günden uzun süredir lonca üyesi.\n2 adet rozet olarak sayılır.",
                color = "A19CDE",
            },
            {
                name = "Ortak",
                description = "30 günden uzun süredir lonca üyesi.",
                color = "A19CDE",
            },
            {
                name = "Yeni",
                description = "Siyah Atlı Kurye'ye hoş geldiniz!\n\n|cFDFFBFNOT: Bu bir rütbesiz rozettir.|r",
                color = "C5C29E",
            },
        }
    },
    {
        name = "Etkinlik Rozetleri",
        description = "Üyelere lonca etkinliklerine olan katılımları için verilen rozetlerdir. Bu rozetler lonca içerisinde rütbenizin yükselmesi için esas alınır. Birkaç kez kazanılabilir.",
        badges = {
            {
                name = "Müzayede",
                description = "Bu rozeti kazanabilmek için bir lonca Müzeyedesine katılıp teklif verdiğiniz bir şeyleri kazanın. Bir müzayede içerisinde birkaç kez kazanılabilir.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Korkusuz",
                description = "Bu rozeti kazanabilmek için PVE lonca etkinliğine katılıp en az bir önemli etkinliği tamamlayın.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Gladyatör",
                description = "Bu rozeti kazanabilmek için PVP lonca etkinliğine katılıp en az bir önemli etkinliği tamamlayın.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Şampiyon",
                description = "Haftanın her etkinliğinden bir rozet kazanın.\n\n|cFDFFBFNOT: Bu rozeti yalnızca hafta içerisinde birden fazla etkinlik varsa kazanabilirsiniz.|r",
                color = "C64343",
                limit = false,
            },
        }
    },
    {
        name = "Ticaret Rozetleri",
        description = "Üyelere ekonomideki başarıları için verilen rozetlerdir. Bu rozetler lonca içerisinde rütbenizin yükselmesi için esas alınır. Haftada bir kez kazanılabilir.",
        badges = {
            {
                name = "Milyoner",
                description = "10 Tüccar rozeti veya 10 Girişimci rozeti kazandı.\n100 adet rozet olarak sayılır.",
                color = "55C855",
                limit = false,
            },
            {
                name = "En İyi Tüccar",
                description = "Lonca Tüccarımız varken en iyi 5 satıcı içerisinde oldu.",
                color = "55C855",
                limit = 10,
                turnsInto = "Girişimci"
            },
            {
                name = "Girişimci",
                description = "10 kez En İyi Tüccar rozeti kazandı.\n10 adet rozet olarak sayılır.",
                color = "55C855",
                limit = 10,
                turnsInto = "Milyoner"
            },
            {
                name = "Satıcı",
                description = "Bir hafta içerisinde 50k altından daha yüksek satış yaptı.",
                color = "55C855",
                limit = 10,
                turnsInto = "Tüccar"
            },
            {
                name = "Tüccar",
                description = "10 kez Satıcı rozeti kazandı.\n10 adet rozet olarak sayılır.",
                color = "55C855",
                limit = 10,
                turnsInto = "Milyoner"
            },
        }
    },
    {
        name = "Bağış Rozetleri",
        description = "Üyelere lonca bankasına yaptıkları bağışlar için verilen rozetlerdir. Bu rozetler lonca içerisinde rütbenizin yükselmesi için esas alınır. Birkaç kez kazanılabilir.",
        badges = {
            {
                name = "Abone",
                description = "5k altından fazla bağış yaptı.",
                color = "97FFBE",
                limit = 10,
                turnsInto = "Destekleyici"
            },
            {
                name = "Destekleyici",
                description = "50k altından fazla bağış yaptı.\n10 adet rozet olarak sayılır.",
                color = "97FFBE",
                limit = 2,
                turnsInto = "Hayırsever"
            },
            {
                name = "Hayırsever",
                description = "100k altından fazla bağış yaptı.\n20 adet rozet olarak sayılır.",
                color = "97FFBE",
                limit = 5,
                turnsInto = "Yatırımcı"
            },
            {
                name = "Yatırımcı",
                description = "500k altından fazla bağış yaptı.\n100 adet rozet olarak sayılır.",
                color = "97FFBE",
                limit = 2,
                turnsInto = "Sponsor"
            },
            {
                name = "Sponsor",
                description = "1m altından fazla bağış yaptı.\n200 adet rozet olarak sayılır.",
                color = "97FFBE",
                limit = false,
            },
        }
    },
    {
        name = "Rütbesiz Rozetler",
        description = "Niteliklerinizi tanımlayan rozetlerdir. Bu rozetler lonca içerisinde rütbenizin yükselmesi için esas ALINMAZ. Herhangi birini almak için yetkililerden biriyle iletişime geçin.",
        badges = {
            {
                name = "Zanaat Ustası",
                description = "Herhangi bir kategorideki her ekipmanı ya da erzağı üretebilir.",
                color = "2DFFF8",
            },
            {
                name = "Özellik Ustası",
                description = "Araştırma malzemeleri sağlayabilir.",
                color = "2DFFF8",
            },
            {
                name = "Stil Ustası",
                description = "Oyundaki her bir çeşit üretim stilini araştırdı.",
                color = "2DFFF8",
            },
            {
                name = "Demirci",
                description = "Silah veya ağır zırh yapabilir.",
                color = "5EB9D7",
            },
            {
                name = "Terzi",
                description = "Hafif veya ortalama zırh yapabilir.",
                color = "5EB9D7",
            },
            {
                name = "Marangoz",
                description = "Asa veya kalkan yapabilir.",
                color = "5EB9D7",
            },
            {
                name = "Kuyumcu",
                description = "Kolye veya yüzük yapabilir.",
                color = "5EB9D7",
            },
            {
                name = "Simyacı",
                description = "İksir veya zehir yapabilir.",
                color = "5EB9D7",
            },
            {
                name = "Efsuncu",
                description = "Eşya efsunlayabilir.",
                color = "5EB9D7",
            },
            {
                name = "Aşçı",
                description = "Yemek pişirebilir veya içecek hazırlayabilir.",
                color = "5EB9D7",
            },
            {
                name = "Tank",
                description = "Trial veya zindanda tank rolü üstlenebilir.",
                color = "FD7A1A",
            },
            {
                name = "Şifacı",
                description = "Trial veya zindanda şifacı rolü üstlenebilir.",
                color = "FD7A1A",
            },
            {
                name = "Savaşçı",
                description = "Trial veya zindanda savaşçı rolü üstlenebilir.",
                color = "FD7A1A",
            },
            {
                name = "Vampir",
                description = "Bedava vampir ısırığı verebilir.",
                color = "879B7D",
            },
            {
                name = "Kurtadam",
                description = "Bedava kurtadam ısırığı verebilir.",
                color = "879B7D",
            },
        }
    },
    {
        name = "Diğer",
        badges = {
            {
                name = "Uzakta",
                description = "Şu anda müsait değil ve rozetin yanında belirtilen tarihte geri dönecek.",
                color = "C5C29E",
            },
            {
                name = "Uyarı",
                description = "Lonca kurallarını çiğnedi ve mail veya sohbet üzerinden uyarıldı.",
                color = "C5C29E",
                limit = 3,
            },
        },
    },
    {
        name = "|cFDFFBFTeşekkürler (Önizleme)|r",
        description = "|cFDFFBFAetherius Badge Filter Yapımcıları|r\n@Arkadius & @sirinsidiator\n\n|cFDFFBFSiyah Atlı Kurye Rozetleri|r\n@CradonWar\n\nSiyah Atlı Kurye verisini yükleyen @sirinsidiator için özel olarak teşekkür ederiz.\n\nLoncamızın bir üyesi olup bu etklentiyi kullandığınız için teşekkür ederiz!\n\n|cFDFFBFSiyah Atlı Kurye - 2018|r",
        badges = {
        },
    },
})
