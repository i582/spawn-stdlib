module main

import json2

test "json Value str method" {
	data := '{ "data": "hello world" }'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': 'hello world'
}", 'actual should be equal to expected')
}

test "json Value with array str method" {
	data := '{ "data": [1, 2, 3, 4, 5] }'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': [1, 2, 3, 4, 5]
}", 'actual should be equal to expected')
}

test "json Value with other object str method" {
	data := '{ "data": { "age": 10 }}'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': {
        'age': 10
    }
}", 'actual should be equal to expected')
}

test "json Value with null" {
	data := '{ "data": { "age": null }}'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': {
        'age': null
    }
}", 'actual should be equal to expected')
}

test "json Value with bool" {
	data := '{ "data": true }'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': true
}", 'actual should be equal to expected')
}

test "json Value with float" {
	data := '{ "data": 10.5 }'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': 10.500000
}", 'actual should be equal to expected')
}

test "json Value with round float" {
	data := '{ "data": 99 }'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'data': 99
}", 'actual should be equal to expected')
}

test "complex json Value" {
	data := '{
  "metadata": {
    "result_type": "recent",
    "iso_language_code": "ja"
  },
  "created_at": "Sun Aug 31 00:29:15 +0000 2014",
  "id": 505874924095815700,
  "id_str": "505874924095815681",
  "text": "@aym0566x \\n\\n名前:前田あゆみ\\n第一印象:なんか怖っ！\\n今の印象:とりあえずキモい。噛み合わない\\n好きなところ:ぶすでキモいとこ😋✨✨\\n思い出:んーーー、ありすぎ😊❤️\\nLINE交換できる？:あぁ……ごめん✋\\nトプ画をみて:照れますがな😘✨\\n一言:お前は一生もんのダチ💖",
  "source": "<a href=\\"http://twitter.com/download/iphone\\" rel=\\"nofollow\\">Twitter for iPhone</a>",
  "truncated": false,
  "in_reply_to_status_id": null,
  "in_reply_to_status_id_str": null,
  "in_reply_to_user_id": 866260188,
  "in_reply_to_user_id_str": "866260188",
  "in_reply_to_screen_name": "aym0566x",
  "user": {
    "id": 1186275104,
    "id_str": "1186275104",
    "name": "AYUMI",
    "screen_name": "ayuu0123",
    "location": "",
    "description": "元野球部マネージャー❤︎…最高の夏をありがとう…❤︎",
    "url": null,
    "entities": {
      "description": {
        "urls": []
      }
    },
    "protected": false,
    "followers_count": 262,
    "friends_count": 252,
    "listed_count": 0,
    "created_at": "Sat Feb 16 13:40:25 +0000 2013",
    "favourites_count": 235,
    "utc_offset": null,
    "time_zone": null,
    "geo_enabled": false,
    "verified": false,
    "statuses_count": 1769,
    "lang": "en"
  }
}
'
	res := json2.raw_decode(data).unwrap()
	res_str := res.str()
	t.assert_eq(res_str, "{
    'in_reply_to_status_id_str': null
    'created_at': 'Sun Aug 31 00:29:15 +0000 2014'
    'id': 505874924095815680
    'in_reply_to_user_id': 866260188
    'user': {
        'screen_name': 'ayuu0123'
        'name': 'AYUMI'
        'lang': 'en'
        'statuses_count': 1769
        'description': '元野球部マネージャー❤︎…最高の夏をありがとう…❤︎'
        'geo_enabled': false
        'entities': {
            'description': {
                'urls': []
            }
        }
        'id_str': '1186275104'
        'followers_count': 262
        'protected': false
        'time_zone': null
        'created_at': 'Sat Feb 16 13:40:25 +0000 2013'
        'id': 1186275104
        'listed_count': 0
        'verified': false
        'favourites_count': 235
        'utc_offset': null
        'url': null
        'friends_count': 252
        'location': ''
    }
    'metadata': {
        'iso_language_code': 'ja'
        'result_type': 'recent'
    }
    'source': '<a href=\\\"http://twitter.com/download/iphone\\\" rel=\\\"nofollow\\\">Twitter for iPhone</a>'
    'in_reply_to_screen_name': 'aym0566x'
    'in_reply_to_status_id': null
    'id_str': '505874924095815681'
    'text': '@aym0566x \\n\\n名前:前田あゆみ\\n第一印象:なんか怖っ！\\n今の印象:とりあえずキモい。噛み合わない\\n好きなところ:ぶすでキモいとこ😋✨✨\\n思い出:んーーー、ありすぎ😊❤️\\nLINE交換できる？:あぁ……ごめん✋\\nトプ画をみて:照れますがな😘✨\\n一言:お前は一生もんのダチ💖'
    'in_reply_to_user_id_str': '866260188'
    'truncated': false
}", 'actual should be equal to expected')
}
