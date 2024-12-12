import synapseclient

# Log in to Synapse
syn = synapseclient.Synapse()
syn.login()

# Define the folder ID
folder_id = 'synXXX'

def get_folder_size(syn, folder_id):
    total_size = 0
    children = syn.getChildren(folder_id)
    
    for child in children:
        if child['type'] == 'org.sagebionetworks.repo.model.FileEntity':
            file_entity = syn.get(child['id'], downloadFile=False)
            total_size += file_entity['fileSize']
        elif child['type'] == 'org.sagebionetworks.repo.model.Folder':
            total_size += get_folder_size(syn, child['id'])
    
    return total_size

# Calculate the total size of the folder in bytes
total_size_bytes = get_folder_size(syn, folder_id)

# Convert the total size to gigabytes
total_size_gb = total_size_bytes / (1024 ** 3)

# Print the total size in gigabytes
print(f"Total size of folder {folder_id}: {total_size_gb:.2f} GB")
