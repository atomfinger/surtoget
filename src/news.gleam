import gleam/bit_array
import gleam/list
import lustre/attribute.{alt, class, href, loading, rel, src, target}
import lustre/element.{type Element}
import lustre/element/html

import gleam/crypto
import gleam/int
import gleam/result
import gleam/string

pub type NewsArticle {
  NewsArticle(
    title: String,
    description: String,
    external_url: String,
    external_image_url: String,
    owner: String,
    date: String,
  )
}

import gleam/dict

pub fn get_news_articles() -> List(NewsArticle) {
  let articles = [
    NewsArticle(
      title: "Sørlandsbanen og Jærbanen: Tilfredsheten blant reisende går ned",
      description: "Tilfredsheten med togene på Sørlandsbanen er stabil, men har gått ørlite ned.",
      external_url: "https://www.dalane-tidende.no/sorlandsbanen-og-jarbanen-tilfredsheten-blant-reisende-gar-ned/s/5-101-826913",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/dala/2024/11/19/12/Skjermbilde_2.JPG?chk=304D51",
      owner: "Dalane Tidende",
      date: "22. desember 2025",
    ),
    NewsArticle(
      title: "Nye problem og innstillingar",
      description: "Ikkje før har ein fått nye lovnader, så står toga på Sørlandsbanen igjen.",
      external_url: "https://www.boblad.no/nyheit/nye-problem-og-innstillingar/387583",
      external_image_url: "https://image.boblad.no/321803.webp?imageId=321803&width=2116&height=1208&format=webp",
      owner: "BøBlad",
      date: "04. desember 2025",
    ),
    NewsArticle(
      title: "Go-Ahead set opp buss for tog i juletrafikken",
      description: "16.000 passasjerar har allereie booka reiser på Sørlandsbanen i jula. Go-Ahead har på førehand sett opp fleire avgangar med buss for tog.",
      external_url: "https://www.nrk.no/sorlandet/go-ahead-set-opp-buss-for-tog-i-juletrafikken-1.17696248",
      external_image_url: "https://gfx.nrk.no/dbiW4HYTF7ZvbzJmVoAgNgglhUIs52rgP7UMWXznooDQ.jpg",
      owner: "NRK",
      date: "18. desember 2025",
    ),
    NewsArticle(
      title: "Innstillinger i togtrafikken torsdag",
      description: "To tog som skulle gått på Sørlandsbanen mellom Oslo, Kristiansand og Stavanger torsdag er innstilt på grunn av problemer med togene. ",
      external_url: "https://www.nrk.no/sorlandet/innstillinger-i-togtrafikken-torsdag-1.17697646",
      external_image_url: "",
      owner: "NRK",
      date: "18. desember 2025",
    ),
    NewsArticle(
      title: "To av åtte står: Manglar tog på søndagar",
      description: "Go-Ahead meiner det som skjer på Sørlandsbanen er resultat av 25 år utan skikkeleg vedlikehald. Selskapet beklagar overfor kundane, men trur det går framover.",
      external_url: "https://www.boblad.no/nyheit/to-av-atte-star-manglar-tog-pa-sondagar/387104",
      external_image_url: "https://image.boblad.no/242422.webp?imageId=242422&width=2116&height=1208&format=webp",
      owner: "BøBlad",
      date: "01. desember 2025",
    ),
    NewsArticle(
      title: "Innstillinger i togtrafikken",
      description: "To tog som skulle gått på Sørlandsbanen mellom Oslo, Kristiansand og Stavanger er innstilt i dag på grunn av problemer med togene.",
      external_url: "https://www.nrk.no/sorlandet/innstillinger-i-togtrafikken-1.17696200",
      external_image_url: "https://gfx.nrk.no/h4UqRBM89E0doFZxir_irg6xZrHLLG_FjbwN_pUKtBpw.jpg",
      owner: "NRK",
      date: "17. desember 2025",
    ),
    NewsArticle(
      title: "Flere tog innstilt i helgen",
      description: "Flere tog som skulle gått på Sørlandsbanen mellom Oslo, Kristiansand og Stavanger denne helgen er innstilt.",
      external_url: "https://www.nrk.no/sorlandet/flere-tog-innstilt-i-helgen-1.17672478",
      external_image_url: "https://gfx.nrk.no/h4UqRBM89E0doFZxir_irg6xZrHLLG_FjbwN_pUKtBpw.jpg",
      owner: "NRK",
      date: "29. november 2025",
    ),
    NewsArticle(
      title: "Togene går nesten som planlagt: – Erfaring tilsier at det blir humpete",
      description: " Fredag lovet Go-Ahead at alt skulle gå på skinner for togene på Sørlandsbanen denne uka. Men togselskapet måtte likevel trekke i nødbremsen for en av formiddagens avganger.",
      external_url: "https://www.nrk.no/sorlandet/go-ahead-forventer-at-togene-pa-sorlandsbanen-gar-som-normalt-mandag-1.17663114",
      external_image_url: "https://gfx.nrk.no/i6TYYMsS9hY0lrgswcNPMQ1rosA1yLu4LCNlbOWtwI4Q.jpg",
      owner: "NRK",
      date: "24. november 2025",
    ),
    NewsArticle(
      title: "Ni toginnstillinger på Sørlandsbanen i dag",
      description: "Go-ahead har færre togsett tilgjengelig enn vanlig. Derfor er hele ni togavganger på Sørlandsbanen mellom Stavanger, Kristiansand og Oslo innstilt i dag. ",
      external_url: "https://www.nrk.no/rogaland/ni-toginnstillinger-pa-sorlandsbanen-i-dag-1.17660172",
      external_image_url: "https://gfx.nrk.no/uUl2XauH6-h-p1RPbwcMfw2wYMKa31rhyMFEizrB5Xig.jpg",
      owner: "NRK",
      date: "20. november 2025",
    ),
    NewsArticle(
      title: "Punktligheten raser på togene: – Dette blir min siste tur",
      description: "Over 40 prosent av avgangene har blitt kansellert i høst. Med rekordmange innstillinger rømmer pendlerne. Finn Pettersen velger nå kronglete flyrute i stedet.",
      external_url: "https://www.nrk.no/rogaland/pa-sorlandsbanen-har-punktlighetene-pa-togene-rast-de-siste-arene-1.17657229",
      external_image_url: "https://gfx.nrk.no/X0n3s1aXPBdq9rRCqTTU7ABPdFhHb_nOiLsdMt1V4Ljg.jpg",
      owner: "NRK",
      date: "19. november 2025",
    ),
    NewsArticle(
      title: "Mangler fire togsett på Sørlandsbanen",
      description: "De siste dagene har det vært en rekke kanselleringer på Sørlandsbanen. Og flere vil det bli de neste dagene.",
      external_url: "https://www.aftenbladet.no/trafikk/i/d45m41/soertoget-dette-er-togavgangene-som-er-kansellert",
      external_image_url: "https://premium.vgc.no/v2/images/b1a1ecaf-aca7-49f9-8707-efb17554c292?fit=crop&format=auto&h=995&w=1900&s=4a21285f2cf1422c121e46e3a449351aad2f2542",
      owner: "Stavanger Aftenblad",
      date: "19. november 2025",
    ),
    NewsArticle(
      title: "Mange toginnstillinger på Sørlandsbanen",
      description: "Flere tog som skulle gått på Sørlandsbanen mellom Oslo, Kristiansand og Stavanger er innstilt mandag.",
      external_url: "https://www.nrk.no/sorlandet/mange-toginnstillinger-pa-sorlandsbanen-1.17655818",
      external_image_url: "https://gfx.nrk.no/FLUplHUikquKhdgPCOAtZg6eJGjwKHV-nbChZdoNum8Q.jpg",
      owner: "NRK",
      date: "17. november 2025",
    ),
    NewsArticle(
      title: "Innstilt ut uka: – Beklager på det sterkeste",
      description: "Deleproblemer gjør at nattoget fra Stavanger til Oslo tidligst vil være i trafikk igjen fra neste mandag.",
      external_url: "https://www.aftenbladet.no/trafikk/i/zARg94/nattoget-fra-stavanger-til-oslo-innstilt-ut-uka",
      external_image_url: "https://premium.vgc.no/v2/images/c538f50a-60ed-460e-a213-99b7a168759c?fit=crop&format=auto&h=995&w=1900&s=1175140ae9ed42cb1d88d066dce6b3cd64289a68",
      owner: "Stavanger Aftenblad",
      date: "05. november 2025",
    ),
    NewsArticle(
      title: "Over 32.000 toginnstillingar visest ikkje i statistikken",
      description: "Sjølv om buss for tog påverkar reiseopplevinga for folk, så påverkar det ikkje statistikken for punktlegheit hos Bane Nor.",
      external_url: "https://www.nrk.no/norge/over-32.000-toginnstillingar-visest-ikkje-i-statistikken-1.17574607",
      external_image_url: "https://gfx.nrk.no/nXVc1cN62RHA78WBR6muFQmch5mtBk8D1qOouVshiJKA.jpg",
      owner: "NRK",
      date: "29. oktober 2025",
    ),
    NewsArticle(
      title: "Flere innstillinger i togtrafikken",
      description: "Flere tog som skulle gått mellom Stavanger, Kristiansand og Oslo er innstilt i dag på grunn av problemer med togene. Det melder togselskapet Go-Ahead. ",
      external_url: "https://www.nrk.no/sorlandet/flere-innstillinger-i-togtrafikken-1.17630697",
      external_image_url: "https://gfx.nrk.no/aILyt-JiNX4UDr99OLk1bwf_iX8RJ7i_EYPfAMrpWVIw.jpg",
      owner: "NRK",
      date: "29. oktober 2025",
    ),
    NewsArticle(
      title: "Bane Nors nye hysj-plan ",
      description: "Holder trafikkmeldingene ute av nyhetsbildet.",
      external_url: "https://www.vg.no/nyheter/i/gw5RMk/bane-nor-sluttet-aa-dele-trafikkmeldinger-ville-redusere-stoey",
      external_image_url: "https://akamai.vgc.no/v2/images/76e51be6-0a66-4620-abe4-7e296f28bc61?format=auto&w=2160&s=2621a1f9cdf08d55055ae8d4b239a0511bb69463",
      owner: "VG",
      date: "05. oktober 2025",
    ),
    NewsArticle(
      title: "Innstillinger i togtrafikken",
      description: "Innstillinger i togtrafikken",
      external_url: "https://www.nrk.no/sorlandet/innstillinger-i-togtrafikken-1.17590049",
      external_image_url: "",
      owner: "NRK",
      date: "29. september 2025",
    ),
    NewsArticle(
      title: "Lanserte surtoget.no og skapte nasjonal merksemd",
      description: "For John Mikael Lindbakk har togturane mellom Oslo og Lunde blitt meir frustrasjon enn glede. Derfor tok han saka i eigne hender og lanserte surtoget.no",
      external_url: "https://www.boblad.no/nyheit/lanserte-surtogetno-og-skapte-nasjonal-merksemd/372674",
      external_image_url: "https://image.boblad.no/372059.webp?imageId=372059&width=600&format=webp",
      owner: "Bø Blad",
      date: "27. september 2025",
    ),
    NewsArticle(
      title: "Lundeheringen fikk nok av forsinkelsene. Lanserte surtoget.no og skapte nasjonal oppmerksomhet",
      description: "For John Mikael Lindbakk har togturene mellom Oslo og Lunde blitt mer frustrasjon enn glede. Derfor tok han saken i egne hender og lanserte surtoget.no – et digitalt opprop for å få Sørlandsbanen på rett spor igjen.",
      external_url: "https://www.kanalen.no/nyheter/lundeheringen-fikk-nok-av-forsinkelsene-lanserte-surtogetno-og-skapte-nasjonal-oppmerksomhet/372009",
      external_image_url: "https://image.kanalen.no/372059.webp?imageId=372059&width=600&format=webp",
      owner: "Kanalen",
      date: "22. september 2025",
    ),
    NewsArticle(
      title: "Buss for tog på Sørlandsbanen",
      description: "Det går ingen tog mellom Kongsberg og Hokksund og det er satt opp buss for tog på Sørlandsbanen mellom Oslo og Kristiansand. Dette skyldes en feil på grunn av Bane Nor sitt arbeid på jernbanesporet. Det er usikkert når togene går som normalt.",
      external_url: "https://www.nrk.no/sorlandet/buss-for-tog-pa-sorlandsbanen-1.17559667",
      external_image_url: "https://gfx.nrk.no/uUl2XauH6-h-p1RPbwcMfw2wYMKa31rhyMFEizrB5Xig.jpg",
      owner: "NRK",
      date: "09. september 2025",
    ),
    NewsArticle(
      title: "Innstiller avgang på Sørlandsbanen",
      description: "Toget som skulle gått fra Oslo S mot Stavanger klokken 15.23 torsdag ettermiddag er innstilt på grunn av problemer med toget. ",
      external_url: "https://www.nrk.no/sorlandet/innstiller-avgang-pa-sorlandsbanen-1.17554756",
      external_image_url: "",
      owner: "NRK",
      date: "04. september 2025",
    ),
    NewsArticle(
      title: "Store problemer: Vurderte å stanse all togtrafikk",
      description: "Go-Ahead sliter med vedlikeholdet av togene på Sørlandsbanen og Jærbanen. Bare i sommer har det vært over 400 innstillinger – og på et tidspunkt ble det sendt ut en svært dramatisk melding.",
      external_url: "https://www.aftenbladet.no/lokalt/i/W0rEb2/go-ahead-har-hatt-over-400-innstillinger-paa-jaerbanen-og-soerlandsbanen-i-sommer",
      external_image_url: "https://premium.vgc.no/v2/images/eef10787-7d57-4fb3-944b-63924a08e878?fit=crop&format=auto&h=995&w=1900&s=4922e763b00ecba7ff705af7caa9b2fdf95e9f69",
      owner: "Stavanger Aftenblad",
      date: "01. september 2025",
    ),
    NewsArticle(
      title: "Kamp for togstoppene i Telemark: – Vi kan ikke planlegge med forsinkelser",
      description: "Telemark fylkeskommune inviterte fredag 29. august til møte om situasjonen på Sørlandsbanen. Bakgrunnen er at ti togstopp i distriktene i Telemark ble fjernet i 2024 og 2025 – og ifølge Bane Nor er det ikke aktuelt å få dem tilbake i 2026 heller, skriver Siri Blichfeldt Dyrland i et referat fra møtet.",
      external_url: "https://www.kanalen.no/meninger/kamp-for-togstoppene-i-telemark-vi-kan-ikke-planlegge-med-forsinkelser/368247",
      external_image_url: "https://image.kanalen.no/368252.webp?imageId=368252&width=2116&height=1208&format=webp",
      owner: "Kanalen",
      date: "29. august 2025",
    ),
    NewsArticle(
      title: "Varsler buss for tog",
      description: "Reisende på Sørlandsbanen kan møte utfordringer mandag. GoAhead opplyser at flere avganger er innstilt.",
      external_url: "https://www.n247.no/bane-nor-buss-for-tog-goahead/varsler-buss-for-tog/560793",
      external_image_url: "https://image.n247.no/560797.webp?imageId=560797&width=2116&height=1208&format=webp",
      owner: "n247",
      date: "25. august 2025",
    ),
    NewsArticle(
      title: "Osloturen røyk for liv: - Hadde gledet meg i lang tid. Nå er jeg potte sur ",
      description: "Liv Aasmundsen, fysioterapeut gjennom 46 år, hadde gledd seg til jubileet med kollegaer i Oslo onsdag 20. august kl. 13.00. Det rauk på grunn av innstilt tog på Sørlandsbanen. Pressevakta i Go-Ahead legg seg «paddeflat». ",
      external_url: "https://www.ta.no/hadde-gledet-meg-i-lang-tid-na-er-jeg-potte-sur/s/5-50-2159340",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/teav/2025/8/20/17/DSC00505.JPG?chk=3B83C7",
      owner: "TA",
      date: "20. august 2025",
    ),
    NewsArticle(
      title: "Tekniske problemer med fjernstyringen av tog flere steder i landet",
      description: "Problemer med fjernstyringsanlegget til Bane Nor førte til mindre forsinkelser på Sørlandsbanen, Jærbanen og på tog i drammensregionen lørdag. ",
      external_url: "https://www.adressa.no/nyheter/innenriks/i/5E2K06/tekniske-problemer-med-fjernstyringen-av-tog-flere-steder-i-landet",
      external_image_url: "",
      owner: "Adressa",
      date: "16. august 2025",
    ),
    NewsArticle(
      title: "Visste ikke hvor omfat­tende det var",
      description: "Go-Ahead har fortsatt trøbbel med flere av togene som ble tatt ut av drift i slutten av juli. ",
      external_url: "https://www.aftenbladet.no/lokalt/i/lwdOa9/sliter-fortsatt-visste-ikke-hvor-omfattende-det-var",
      external_image_url: "https://premium.vgc.no/v2/images/a4887169-17c6-4c24-b944-402c591bd977?fit=crop&format=auto&h=1267&w=1900&s=a30b1a91d29aba185ec3d47509cef70abb986e57",
      owner: "Stavanger Aftenblad",
      date: "11. august 2025",
    ),
    NewsArticle(
      title: "Nye innstillinger på Sørlandsbanen: – Fullstendig krise",
      description: "Den siste uken har vært preget av innstillinger for Sørlandsbanen. Disse ser ut til å vedvare. Situasjonen er uholdbar, mener pendler.",
      external_url: "https://www.nrk.no/rogaland/nye-innstillinger-pa-sorlandsbanen_-_-fullstendig-krise-nar-alle-regiontog-tas-ut-av-trafikk-1.17516021",
      external_image_url: "https://gfx.nrk.no/dZe4wF7CS68eU4F5Ys_LZASbMDulw5zOSRaufS-I2nQw.jpg",
      owner: "NRK",
      date: "04. august 2025",
    ),
    NewsArticle(
      title: "Innstillingar også kommande veke",
      description: "Togtrafikken mellom Oslo, Kristiansand og Stavanger vil framleis vere redusert dei kommande dagane.",
      external_url: "https://www.nrk.no/sorlandet/innstillingar-ogsa-kommande-veke-1.17514370",
      external_image_url: "https://gfx.nrk.no/umkc38JlKJTZqKNhx3j03wwq_DTLcCv7YZVS4KNAXhgQ.jpg",
      owner: "NRK",
      date: "03. august 2025",
    ),
    NewsArticle(
      title: "Flere avganger på Sørlandsbanen etter innstillinger",
      description: "Go-Ahead gjeninnfører flere togavganger på Sørlandsbanen fra og med torsdag, etter at kun én avgang daglig har vært i drift de siste dagene. Årsaken til de tidligere innstillingene var løse sideruter som ble oppdaget på flere togsett, noe som førte til at åtte tog av type 73 ble tatt ut av drift. Etter grundige stresstester og inspeksjoner blir togene nå satt tilbake i trafikk. Enkelte avganger vil fremdeles være innstilt frem til fredag for å fullføre de siste testene, og det vil bli organisert alternativ transport for de berørte reisende.",
      external_url: "https://www.abcnyheter.no/nyheter/flere-avganger-pa-sorlandsbanen-etter-innstillinger/1152046",
      external_image_url: "https://image.abcnyheter.no/1146712.webp?imageId=1146712&width=2116&height=1208&format=webp",
      owner: "ABC Nyheter",
      date: "29. juli 2025",
    ),
    NewsArticle(
      title: "Kun én avgang om dagen med Sørlandsbanen",
      description: "Fram til og med onsdag er det kun én daglig avgang på Sørlandsbanen i hver retning. Årsaken er at det er oppdaget løse sideruter på åtte togsett (type 73), som nå er tatt ut av drift for reparasjon.",
      external_url: "https://www.nrk.no/sorlandet/kun-en-avgang-om-dagen-med-sorlandsbanen--1.17504983",
      external_image_url: "https://gfx.nrk.no/FLUplHUikquKhdgPCOAtZg6eJGjwKHV-nbChZdoNum8Q.jpg",
      owner: "NRK",
      date: "25. juli 2025",
    ),
    NewsArticle(
      title: "Togvindu løsnet – avganger innstilt",
      description: "Go-Ahead har innstilt alle regiontogavganger av type 73 på Sørlandsbanen etter at et sidevindu løsnet på et tog. Åtte togsett er tatt ut av tjeneste for inspeksjon, og det er funnet løse vinduer på tre av dem. Nattogene går som normalt.",
      external_url: "https://www.nrk.no/sorlandet/avganger-pa-sorlandsbanen-er-innstilt-1.17503849",
      external_image_url: "https://gfx.nrk.no/uUl2XauH6-h-p1RPbwcMfwDXKlNquOnXuMFEizrB5Xig.jpg",
      owner: "NRK",
      date: "24. juli 2025",
    ),
    NewsArticle(
      title: "Go-Ahead melder om togtrøbbel i dag, tysdag",
      description: "Togselskapet Go-Ahead melder om togtrøbbel på Sørlandsbanen tirsdag. Avgangen fra Stavanger klokka 4.20 mot Oslo er innstilt. Det blir satt opp buss for tog på strekningen mellom Stavanger og Kongsberg.",
      external_url: "https://www.boblad.no/nyheit/go-ahead-melder-om-togtrobbel-i-dag-tysdag/360802",
      external_image_url: "https://image.boblad.no/305005.webp?imageId=305005&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "21. juli 2025",
    ),
    NewsArticle(
      title: "Rim tvang tog til å snu i motbakke – mener Bane Nor kunne løst problemet raskere",
      description: "Rim på kontaktledningen på Sørlandsbanen førte til at tog måtte snu i en motbakke, noe som skapte forsinkelser. Go Ahead Nordic kritiserer Bane NOR for treg problemløsning.",
      external_url: "https://www.tu.no/artikler/rim-tvang-tog-til-a-snu-i-motbakke-mener-bane-nor-kunne-lost-problemet-raskere-br/554340",
      external_image_url: "https://images.gfx.no/1000x/2867/2867644/NTB_HIO_aa45YWU.jpg",
      owner: "TU",
      date: "03. januar 2025",
    ),
    NewsArticle(
      title: "Avsporing på Sandnes: – Trafikken vil nok stort sett gå som normalt",
      description: "Et tomt tog har sporet av ved Skeiane stasjon i Sandnes, noe som forårsaker forsinkelser på Sørlandsbanen. Togtrafikken forventes likevel å gå stort sett som normalt, da andre spor er tilgjengelige.",
      external_url: "https://www.nrk.no/rogaland/avsporing-pa-sandnes_-_-trafikken-vil-nok-stort-sett-ga-som-normalt-1.17218999",
      external_image_url: "https://gfx.nrk.no/OxNJVxbO4jw-Pyhti0Y_TAVkW3t8hDUPaFsmESJWateA.jpg",
      owner: "NRK",
      date: "23. januar 2025",
    ),
    NewsArticle(
      title: "Esa vurderer å åpne sak mot Norge etter tildelingen av Sørlandsbanen til Vy",
      description: "Eftas overvåkingsorgan, Esa, vurderer å åpne sak mot Norge etter at Jernbanedirektoratet i oktober i fjor tildelte Sørlandsbanen til Vy og vraket Go-Ahead.",
      external_url: "https://www.finansavisen.no/politikk/2025/05/15/8264298/esa-vurderer-a-apne-sak-mot-norge-etter-tildelingen-av-sorlandsbanen-til-vy",
      external_image_url: "https://imaginary.finansavisen.no/aoi-cover?width=2560&height=1440&top=834&left=382&areawidth=1518&areaheight=994&url=https%3A%2F%2Fsmooth-storage.aptoma.no%2Fusers%2Fhegnar%2Fimages%2F107652070.jpg%3Ft%5Bquality%5D%3D100%26%26accessToken%3Dbabc1782acf1bdd757801aefa6fc4321d3b70c4bd2ee7103187b6ddd5b1e75bc",
      owner: "Finansavisen",
      date: "15. mai 2025",
    ),
    NewsArticle(
      title: "Står saman: – Me jobbar vidare for at toga skal stoppe der folk bur",
      description: "Tre ordførere i Telemark kjemper for bedre togtilbud i regionen.",
      external_url: "https://www.boblad.no/nyheit/star-saman-me-jobbar-vidare-for-at-toga-skal-stoppe-der-folk-bur/336999",
      external_image_url: "https://image.boblad.no/337003.webp?imageId=337003&x=5.59&y=27.32&cropw=81.28&croph=52.19&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "15. mai 2025",
    ),
    NewsArticle(
      title: "Togtrøbbel skyldes slitte hjul",
      description: "Slitte togshjul forårsaker forsinkelser og innstillinger på Sørlandsbanen. Nye hjul ventes, men tidspunkt for utskifting er ukjent.",
      external_url: "https://www.nrk.no/sorlandet/togtrobbel-skyldes-slitte-hjul-1.17443405",
      external_image_url: "https://gfx.nrk.no/FLUplHUikquKhdgPCOAtZg6eJGjwKHV-nbChZdoNum8Q.jpg",
      owner: "NRK",
      date: "04. juni 2025",
    ),
    NewsArticle(
      title: "Får ikke togstopp tilbake",
      description: "Digitalt møte i Togforum Sørlandsbanen skuffet ordførere som håpet på gjenåpning av togstopp.",
      external_url: "https://www.drangedalsposten.no/far-ikke-togstopp-tilbake/s/5-164-34639",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/dran/2025/6/8/14/utekontor.jpg?chk=24FA34",
      owner: "Drangedalsposten",
      date: "08. juni 2025",
    ),
    NewsArticle(
      title: "Sørlandsbanen digitaliseres",
      description: "Bane NOR digitaliserer Sørlandsbanen ved å erstatte dagens signalsystem med ERTMS. Dette skal redusere forsinkelser og øke togfrekvensen.",
      external_url: "https://www.banenor.no/prosjekter/alle-prosjekter/ertms-fremtidens-signalsystem/aktuelt-om-ertms/sorlandbanen-digitaliseres/",
      external_image_url: "https://www.banenor.no/contentassets/4aea6634ca014ecd93341f302c1cda54/ertms_holmlia_foto-liv-tone-otterholt_nett.jpg?format=avi1&width=1680&height=1120&quality=80",
      owner: "Bane NOR",
      date: "10. juli 2025",
    ),
    NewsArticle(
      title: "Skal ha nytt møte med Bane Nor – er ikkje fornøgde",
      description: "Nytt møte i Sørlandsbanen togforum der forsvinning av togstopp ble diskutert.",
      external_url: "https://www.boblad.no/nyheit/skal-ha-nytt-mote-med-bane-nor-er-ikkje-fornogde/357587",
      external_image_url: "https://image.boblad.no/357616.webp?imageId=357616&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "30. juni 2025",
    ),
    NewsArticle(
      title: "Tog mellom Stavanger og Kongsberg i dag innstilt",
      description: "Go-Ahead Nordic har kansellert et tog på grunn av et problem og råder passasjerer til å ta neste tog.",
      external_url: "https://www.boblad.no/nyheit/tog-mellom-stavanger-og-kongsberg-i-dag-innstilt/360132",
      external_image_url: "https://image.boblad.no/174848.webp?imageId=174848&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "16. juli 2025",
    ),
    NewsArticle(
      title: "Signalfeil får konsekvenser for Sørlandsbanen",
      description: "En signalfeil i Oslo skaper forsinkelser og innstillinger for Sørlandsbanen, som går til og fra Oslo. Ingen tog kan passere Oslo på grunn av feilen.",
      external_url: "https://www.nrk.no/stor-oslo/full-stans-i-togtrafikken-pa-ostlandet-1.17340830",
      external_image_url: "https://gfx.nrk.no/lRhO5YMIPnGG9ilUJdcIWgGa6gx2aH0aK_Vghre7plEA.jpg",
      owner: "NRK",
      date: "15. mars 2025",
    ),
    NewsArticle(
      title: "Store togproblemer på Sørlandsbanen",
      description: "Det er meldt om store problemer for tog mellom Marnardal og Audnedal. Mye rim på kjøretråden gir dårlig kontakt mellom tog og kjøretråd, noe som fører til strømproblemer.",
      external_url: "https://www.nrk.no/sorlandet/store-togproblemer-pa-sorlandsbanen-1.17189263",
      external_image_url: "https://gfx.nrk.no/xTBdyfd8MOT7mtRWnun-4g8SKcchDTAlXmyV0ptecHAw.jpg",
      owner: "NRK",
      date: "10. november 2024",
    ),
    NewsArticle(
      title: "Vy tar over Sørlandsbanen - Go-Ahead Nordic vrakes",
      description: "Den statseide togselskapet Vy tar over Sørlandsbanen, Arendalsbanen og Jærbanen fra Go-Ahead Nordic fra desember 2027.",
      external_url: "https://www.nrk.no/sorlandet/vy-tar-over-sorlandsbanen-_-go-ahead-nordic-vrakes-1.17094076",
      external_image_url: "https://gfx.nrk.no/hgJLNVrVhRS-J1gOrBvWygRXp7yx4sW44VmMgM0k9KiA.jpg",
      owner: "NRK",
      date: "25. oktober 2024",
    ),
    NewsArticle(
      title: "Flere ordførere i Telemark kjemper for å få tilbake stopp på Sørlandsbanen",
      description: "Fire ordførere fra Telemark har sendt et brev til stortingspolitikerne der de kritiserer Bane Nor for å ha fjernet stopp på Sørlandsbanen, noe de mener har forverret punktligheten.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/flere-ordforere-i-telemark-kjemper-for-a-fa-tilbake-stopp-pa-sorlandsbanen-1.17092301",
      external_image_url: "https://gfx.nrk.no/8tySAizN-1qRWm0521Z1Wwk33kXVrLgfzcBuUBmItZ0w.jpg",
      owner: "NRK",
      date: "28. oktober 2024",
    ),
    NewsArticle(
      title: "Fikk tre timer i Drangedal",
      description: "Reisende med toget fra Stavanger til Oslo søndag ettermiddag fikk anledning til å studere omgivelsene rundt stasjonen i Prestestranda i rundt tre timer før turen kunne gå videre.",
      external_url: "https://www.drangedalsposten.no/fikk-tre-timer-i-drangedal/s/5-164-34904",
      external_image_url: "",
      owner: "Drangedalsposten",
      date: "16. juni 2025",
    ),
    NewsArticle(
      title: "Stor aktør på Jærbanen trekker seg: Frykter mer buss for tog",
      description: "Selskapet som vedlikeholder togene på Sørlandsbanen, terminerte kontrakten etter store økonomiske tap. Nå overtar Go-Ahead arbeidet selv.",
      external_url: "https://www.aftenbladet.no/lokalt/i/dRe2j1/stor-aktoer-paa-jaerbanen-trekker-seg-frykter-mer-buss-for-tog",
      external_image_url: "https://premium.vgc.no/v2/images/8d8574ae-b5f7-45d1-a430-053142232d54?fit=crop&format=auto&h=995&w=1900&s=df82e18af61f9b4734df0b06c288f2d93af1f07c",
      owner: "Aftenbladet",
      date: "26. mai 2025",
    ),
    NewsArticle(
      title: "Buss for tog i sommar",
      description: "Sidan pendlarane har ferie og det er færre som tar tog, nyttar Bane Nor moglegheitene til vedlikehalds- og byggearbeid på togstrekningane.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/buss-for-tog-i-sommar-1.17424797",
      external_image_url: "https://gfx.nrk.no/E1nhPRb6k7GReJkcTROcIg5Xo1p44-YoUgEFoTF7St0g",
      owner: "NRK",
      date: "20. mai 2025",
    ),
    NewsArticle(
      title: "Sørlandsbanen: Har aldri vært verre",
      description: "Sørlandsbanen har lavest punktlighet – tiltakene gir liten effekt så langt.",
      external_url: "https://www.dalane-tidende.no/sorlandsbanen-har-aldri-vart-verre/s/5-101-741316",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/dala/2022/11/6/14/Go%2BAhead%2B19.07.20%2B(20)%2BDriftsbanegrden%2BKongsberg_1.jpg?chk=8714D3",
      owner: "Dalene Tidene",
      date: "19. januar 2025",
    ),
  ]
  list.sort(articles, by: fn(a, b) {
    case parse_date(a.date), parse_date(b.date) {
      Ok(date_a), Ok(date_b) -> string.compare(date_b, date_a)
      _, _ -> string.compare(a.date, b.date)
      // Fallback to string comparison if parsing fails
    }
  })
}

fn parse_date(date_string: String) -> Result(String, Nil) {
  let month_map =
    dict.from_list([
      #("januar", "01"),
      #("februar", "02"),
      #("mars", "03"),
      #("april", "04"),
      #("mai", "05"),
      #("juni", "06"),
      #("juli", "07"),
      #("august", "08"),
      #("september", "09"),
      #("oktober", "10"),
      #("november", "11"),
      #("desember", "12"),
    ])

  let parts = string.split(date_string, " ")
  case parts {
    [day_str, month_name, year_str] -> {
      let cleaned_day_str = case string.ends_with(day_str, ".") {
        True -> string.slice(day_str, 0, string.length(day_str) - 1)
        False -> day_str
      }
      use day <- result.try(int.parse(cleaned_day_str))
      use _year <- result.try(int.parse(year_str))
      use month_num <- result.try(dict.get(month_map, month_name))

      let formatted_day = case day < 10 {
        True -> "0" <> int.to_string(day)
        False -> int.to_string(day)
      }
      Ok(year_str <> "-" <> month_num <> "-" <> formatted_day)
    }
    _ -> Error(Nil)
  }
}

pub fn get_image_id(article: NewsArticle) -> String {
  crypto.hash(crypto.Sha1, bit_array.from_string(article.external_image_url))
  |> bit_array.base16_encode()
}

pub fn get_image_url(article: NewsArticle) -> String {
  "/news/images/" <> get_image_id(article)
}

pub fn find_article_by_image_id(image_id: String) -> Result(NewsArticle, Nil) {
  get_news_articles()
  |> list.filter(fn(article) { get_image_id(article) == image_id })
  |> list.first()
}

pub fn render(articles: List(NewsArticle)) -> Element(a) {
  html.div([class("py-12 bg-gray-50")], [
    html.div([class("max-w-7xl mx-auto px-4 sm:px-6 lg:px-8")], [
      html.div([class("text-center")], [
        html.h2(
          [
            class(
              "text-base text-yellow-600 font-semibold tracking-wide uppercase",
            ),
          ],
          [html.text("Siste Nytt")],
        ),
        html.p(
          [
            class(
              "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl",
            ),
          ],
          [html.text("Oppdateringer om Sørlandsbanen")],
        ),
      ]),
      html.div(
        [class("mt-12 space-y-8")],
        list.map(articles, fn(article) {
          html.a(
            [
              href(article.external_url),
              target("_blank"),
              rel("noopener noreferrer"),
              class(
                "block md:flex bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 overflow-hidden",
              ),
            ],
            [
              html.div([class("md:w-1/3")], [
                html.img([
                  loading("lazy"),
                  src(get_image_url(article)),
                  alt(article.title),
                  class("w-full h-full object-cover max-h-80 md:max-h-full"),
                ]),
              ]),
              html.div([class("md:w-2/3 p-6 flex flex-col justify-between")], [
                html.div([], [
                  html.h3([class("text-2xl font-bold text-gray-900 mb-2")], [
                    html.text(article.title <> " [" <> article.owner <> "]"),
                  ]),
                  html.p([class("text-gray-700 text-base mb-4")], [
                    html.text(article.description),
                  ]),
                ]),
                html.p([class("text-gray-500 text-sm")], [
                  html.text(article.date),
                ]),
              ]),
            ],
          )
        }),
      ),
      html.div([class("mt-12 text-center")], [
        html.p([class("text-gray-600")], [
          html.text("Mangler vi en sak? Send den til "),
          html.a(
            [
              href("mailto:tips@surtoget.no"),
              class("text-yellow-600 hover:underline"),
            ],
            [html.text("tips@surtoget.no")],
          ),
        ]),
      ]),
    ]),
  ])
}
