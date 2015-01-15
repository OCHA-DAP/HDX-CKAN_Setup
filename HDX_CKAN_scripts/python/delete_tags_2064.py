import requests
import json
from io import StringIO
server = 'http://localhost:5000'
key = 'xxxxx'

tags = ['585e109c-a48d-4d2e-9cc2-74b42b956951',
        '7395de11-d6cd-488d-87a0-e47df9b7d46b',
        'bd497760-0ed3-4466-a7f2-74254f835493',
        '678eec89-0bd3-4eab-8443-7d8078a9571a',
        'bbd6396d-780e-42fb-b6cf-bf1a908ed1ef',
        'd959b74e-25fa-4b3d-b316-e36913c0d422',
        '1a706779-0e1a-4812-acad-194dafce2e50',
        'a6395c2f-b831-4204-b671-9ac08967f150',
        'e5aabb9b-2938-4fab-b6d7-b27fe580b121',
        '27614b2f-e75e-45b4-bf38-13e6cab27b6f',
        '044b30ac-45ad-4f37-86c0-12a123623ae4',
        '8182131f-3329-495b-a120-d78d59ae0584',
        'd9340f87-4fd1-437f-ac78-f435255b244d',
        '82e5bd4a-bff1-434e-99fa-10175ea98684',
        '51cdfbb6-3eca-41fd-9f02-35365549c779',
        '21f84cdb-18cf-4f10-a9a7-8d0d056f4053',
        '2c25ffe4-3d92-4e7f-a553-48b75507380c',
        '71327b97-34dd-4ad5-944e-b3d48c2ddbc4',
        '53d7902a-9a85-4684-9fcd-f4187aa99ed9',
        '886096ca-7b5b-4df7-a632-e649c680af37',
        '9b8670b4-8b7e-4a7a-b4ef-73a55d577db3',
        '333518a0-15bf-449d-a1dd-857084b789e4',
        '6cf99446-f912-41a3-88e6-770298e710a3',
        'aa7bc5b3-b0ad-4283-9fd7-68b42d520227',
        '4f657387-d500-411e-af73-05bf24a8f5f0',
        '01020fd5-5217-4277-bf93-800131868f10',
        'efac3ef8-24f6-42a9-8a5a-dad520e61e38',
        '26dfcab8-bef7-4f9b-aa45-a45b558e1456',
        '087f2bd5-d943-4a00-a8ce-aeb968b91e93',
        'ccedaf0e-e6c7-419b-aa52-8ac278881a3e',
        '21de6e2f-d483-4e8a-8b0a-a191cedff91c',
        'd9de6cda-9829-4b81-83ef-07982206230d',
        '86278d7d-4442-4e79-a75b-6155d884f3d9',
        '72414792-ce2c-47d9-8c63-ac4c2c1ee9dd',
        '21e12295-bb05-40ec-b8bd-d0cbcf720aa4',
        'f0f96f6c-bfa3-46e6-82ff-18a7e889d592',
        '8eb34bf1-a631-4188-bd22-17e3e92325c8',
        '19dc056f-dd33-4663-be26-ac34eba887ef',
        '9ada8620-c6b0-4027-a7f6-819100dc9a11',
        'ac3f03e2-b258-49a8-a7c5-a56eb5009557',
        'ca225da4-6eb4-4bef-aca8-7d479595a8d6',
        'telecommunication',
        'telecommunications',
        'emergency',
        'humanitarian finance',
        'food',
        'nutrition']

base = server + '/api/action/tag_delete'
for tag in tags:
    res = requests.post(base, data=json.dumps({'id': tag}), headers={
        "Authorization": key, 'content-type': 'application/json'}, verify=False)
    print 'finishing delete : ' + res.url + '/' + tag
