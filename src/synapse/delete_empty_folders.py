import synapseclient

# Log in to Synapse
syn = synapseclient.Synapse()
syn.login()

# Define the project ID
project_id = 'synXXX'

def find_empty_folders(syn, parent_id):
    empty_folders = []
    children = syn.getChildren(parent_id)
    
    for child in children:
        if child['type'] == 'org.sagebionetworks.repo.model.Folder':
            # Recursively check if the folder is empty
            sub_empty_folders = find_empty_folders(syn, child['id'])
            if not sub_empty_folders:
                # Check if the folder itself is empty
                sub_children = list(syn.getChildren(child['id']))
                if not sub_children:
                    empty_folders.append(child['id'])
            else:
                empty_folders.extend(sub_empty_folders)
    
    return empty_folders

def delete_empty_folders(syn, empty_folders):
    for folder_id in empty_folders:
        syn.delete(folder_id)
        print(f"Deleted empty folder: {folder_id}")

# Find empty folders in the project
empty_folders = find_empty_folders(syn, project_id)

# Delete the empty folders
delete_empty_folders(syn, empty_folders)
