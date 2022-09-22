import greenworks from 'greenworks';
import os from 'os';

// https://partner.steamgames.com/doc/store/localization
const languages = {
  arabic: 'ar',
  bulgarian: 'bg',
  schinese: 'zh-CN',
  tchinese: 'zh-TW',
  czech: 'cs',
  danish: 'da',
  dutch: 'nl',
  english: 'en',
  finnish: 'fi',
  french: 'fr',
  german: 'de',
  greek: 'el',
  hungarian: 'hu',
  italian: 'it',
  japanese: 'ja',
  koreana: 'ko',
  norwegian: 'no',
  polish: 'pl',
  portuguese: 'pt',
  brazilian: 'pt-BR',
  romanian: 'ro',
  russian: 'ru',
  spanish: 'es',
  latam: 'es-419',
  swedish: 'sv',
  thai: 'th',
  turkish: 'tr',
  ukrainian: 'uk',
  vietnamese: 'vn',
};

function forceLanguage(language) {
  const supportedLanguages = ['en', 'fr'];
  if (supportedLanguages.includes(language)) {
    // console.log(`detected steam language: ${language} is supported`);
    return language;
  }
  // console.log(`detected steam language: ${language} is not supported, falling back to en`);
  return 'en';
}

export default async function initSteamAPI() {
  // console.log('test steam api');

  if (!greenworks) {
    return { error: `Rising Constellation does not support your platform: ${os.platform()}` };
  }

  let init;
  try {
    init = greenworks.init();
  } catch (err) {
    if (!greenworks.isSteamRunning()) {
      return { error: 'Steam is not running!' };
    }
    return { error: 'Could not initialize Steam API.' };
  }
  if (init) {
    greenworks._steam_events.on = (...args) => greenworks.emit(...args);
    console.log('Steam API initialized successfully.');

    greenworks.on('steam-servers-connected', () => { console.log('connected'); });
    greenworks.on('steam-servers-disconnected', () => { console.log('disconnected'); });
    greenworks.on('steam-server-connect-failure', () => { console.log('connected failure'); });
    greenworks.on('steam-shutdown', () => { console.log('shutdown'); });

    // greenworks.getStatInt('totallyfake',
    //   (stat) => { console.log('got stat back', stat); },
    //   (_err) => { console.log('Failed on getting stat.'); });

    // greenworks.getNumberOfPlayers(
    //   (a) => { console.log('Number of players ' + a); },
    //   (_err) => { console.log('Failed on getting number of players'); },
    // );

    // console.log('Numer of friends: '
    //     + greenworks.getFriendCount(greenworks.FriendFlags.Immediate));
    // const friends = greenworks.getFriends(greenworks.FriendFlags.Immediate);
    // const friendsName = [];
    // for (let i = 0; i < friends.length; i += 1) friendsName.push(friends[i].getPersonaName());
    // console.log('Friends: [' + friendsName.join(',') + ']');
    const steamGameLang = greenworks.getCurrentGameLanguage() || greenworks.getCurrentUILanguage();
    const languageCode = forceLanguage(languages[steamGameLang]);
    return {
      lang: languageCode,
    };
  }
  return { error: 'Unknown Steam error' };
}
