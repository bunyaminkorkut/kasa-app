import 'package:google_mobile_ads/google_mobile_ads.dart';

class KasaBannerAd {
  late final BannerAd bannerAd;

  KasaBannerAd() {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8425387935401647/4877168916',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner failed to load: $error');
        },
      ),
    )..load();
  }
}

class KasaInterstitialAd {
  late final InterstitialAd interstitialAd;

  KasaInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          print('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad failed to load: $error');
        },
      ),
    );
  }
}