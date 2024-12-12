import synapseclient

# Log in to Synapse
syn = synapseclient.Synapse()
syn.login()

# Define the project ID
project_id = 'synXXX'

def find_duplicate_files(syn, parent_id):
    duplicates = {}
    children = syn.getChildren(parent_id)
    
    for child in children:
        if child['type'] == 'org.sagebionetworks.repo.model.FileEntity':
            file_name = child['name'].split(".")[0]
            if file_name not in duplicates:
                duplicates[file_name] = []
            duplicates[file_name].append(child)
        elif child['type'] == 'org.sagebionetworks.repo.model.Folder':
            sub_duplicates = find_duplicate_files(syn, child['id'])
            for key, value in sub_duplicates.items():
                if key not in duplicates:
                    duplicates[key] = []
                duplicates[key].extend(value)
    
    return duplicates

def keep_gzipped_files(syn, duplicates):
    for file_name, files in duplicates.items():
        if len(files) > 1:
            gzipped_files = [f for f in files if f['name'].endswith('.gz')]
            non_gzipped_files = [f for f in files if not f['name'].endswith('.gz')]
            
            if gzipped_files:
                for file in non_gzipped_files:
                    syn.delete(file['id'])
                    print(f"Deleted non-gzipped file: {file['name']} (ID: {file['id']})")

# Find duplicate files in the project
duplicates = find_duplicate_files(syn, project_id)

# Keep only the gzipped versions of the files
keep_gzipped_files(syn, duplicates)
