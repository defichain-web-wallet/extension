import sys
import json

if __name__ == "__main__":
    # param must be 'chrome' or 'firefox'
    param = sys.argv[1]

    index_manifest = open('../web/manifest/index.json', 'r+')
    specific_manifest_part = open(f'../web/manifest/{param}.json')

    target_data = json.load(specific_manifest_part)
    manifest_data = json.load(index_manifest)

    manifest_data.update(target_data)

    index_manifest.close()
    specific_manifest_part.close()

    manifest = open("../web/manifest.json", "w")
    json.dump(manifest_data, manifest)
    manifest.close()

    print(manifest_data)
