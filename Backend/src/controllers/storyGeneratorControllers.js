// storyGenerator.js
import axios from 'axios'; // ✅ Default import

const apiKeys = [
  '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',
  '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',
  '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',
  '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',
  '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'
];

let currentKeyIndex = 0;
const random = () => Math.floor(Math.random() * 20);

// Name pools
const boyNames = ['أحمد', 'محمد', 'علي', 'حسن', 'يوسف', 'خالد', 'عمر', 'سعد', 'فهد', 'نايف', 'راشد', 'سلطان', 'ماجد', 'طارق', 'زياد', 'كريم', 'أنس', 'عبدالله', 'فيصل', 'نواف'];
const girlNames = ['فاطمة', 'عائشة', 'زينب', 'مريم', 'خديجة', 'هند', 'نورا', 'سارة', 'دانة', 'لينا', 'رهف', 'جود', 'ريم', 'شهد', 'غلا', 'روان', 'لمى', 'هيا', 'تالا', 'جنى'];
const animalNames = ['لؤلؤ', 'نجمة', 'شهاب', 'بدر', 'قمر', 'ورد', 'ياسمين', 'عسل', 'سكر', 'فراشة', 'نسيم', 'غيمة', 'مطر', 'شمس', 'نور', 'ضوء', 'أمل', 'حلم', 'سعادة', 'فرح'];
const openers = ['في يوم جميل مشرق', 'عندما أشرقت الشمس الذهبية', 'في صباح مليء بالأمل', 'حين غردت العصافير بفرح', 'في زمن قديم جميل', 'عندما كانت النجوم تلمع', 'في مكان سحري بعيد', 'حيث تنمو الأحلام الجميلة'];
const endings = ['وهكذا تعلم أن', 'ومن ذلك اليوم فهم أن', 'وأدرك في النهاية أن', 'واكتشف أن السر في', 'وعرف أن الحياة تعلمنا أن', 'وفهم أن أجمل ما في الحياة هو'];

function generateCharacterNames(heroType) {
  if (heroType === 'ولد') return { main: boyNames[random()], friend: boyNames[random()] };
  if (heroType === 'بنت') return { main: girlNames[random()], friend: girlNames[random()] };
  if (heroType === 'حيوان' || heroType === 'طائر') return { main: animalNames[random()], friend: animalNames[random()] };
  if (heroType === 'مجموعة') return { main: boyNames[random()], friend: girlNames[random()], third: boyNames[random()] };
  return { main: boyNames[random()], friend: girlNames[random()] };
}

function buildSystemPrompt(age) {
  return `أنت كاتب قصص أطفال محترف ...\nالعمر المستهدف: ${age}`;
}

function buildUserPrompt(context) {
  const { topic, setting, goal, age, length, heroType, characterNames, opener, ending } = context;
  const wordLimit = {
    'قصة قصيرة': '40-75 كلمة',
    'قصة متوسطة': '75-105 كلمة',
    'قصة طويلة': '106-130 كلمة',
  }[length] || '75-105 كلمة';

  return `
اكتب قصة تعليمية كاملة بالعربية:

▪ الموضوع: ${topic}
▪ المكان: ${setting}
▪ الهدف: ${goal}
▪ العمر: ${age} سنة
▪ طول القصة: ${length} (${wordLimit})

👦 الشخصية: ${heroType}
▪ اسم البطل: ${characterNames.main}
▪ الصديق: ${characterNames.friend}

✨ البداية: "${opener}"
🏁 النهاية: "${ending}"

⚠️ اكتب القصة فقط، ولا تتركها ناقصة.
`;
}

function getTokenLimit(length) {
  if (length === 'قصة قصيرة') return 140;
  if (length === 'قصة متوسطة') return 160;
  if (length === 'قصة طويلة') return 180;
  return 140;
}

async function generateStory({ topic, setting, goal, age, length, heroType = 'ولد' }) {
  const characterNames = generateCharacterNames(heroType);
  const opener = openers[random() % openers.length];
  const ending = endings[random() % endings.length];

  const body = {
    model: 'meta-llama/llama-3.1-70b-instruct',
    messages: [
      { role: 'system', content: buildSystemPrompt(age) },
      { role: 'user', content: buildUserPrompt({ topic, setting, goal, age, length, heroType, characterNames, opener, ending }) },
    ],
    max_tokens: getTokenLimit(length),
    temperature: 0.7,
    top_p: 0.9,
    presence_penalty: 0.2,
    frequency_penalty: 0.1,
    stop: ["\n\n\n", "---", "***", "القصة التالية", "قصة أخرى"]
  };

  for (let i = 0; i < apiKeys.length; i++) {
    try {
      const res = await axios.post('https://openrouter.ai/api/v1/chat/completions', body, {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKeys[currentKeyIndex]}`
        }
      });

      const story = res.data.choices[0].message.content.trim();
      return story;
    } catch (err) {
      const status = err.response?.status || 0;
      const isAuthError = [401, 403].includes(status) || JSON.stringify(err.response?.data || '').toLowerCase().includes("unauthorized");

      if (isAuthError && currentKeyIndex < apiKeys.length - 1) {
        currentKeyIndex++;
        continue;
      }

      throw new Error(`Story generation failed: ${err.message}`);
    }
  }

  throw new Error("All API keys failed.");
}

export default { generateStory };
