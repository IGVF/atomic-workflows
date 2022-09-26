# Contributing

Thank you for wanting to contribute. If you have a bug please create an issue. The issue should contain

- the command ran,
- the error message, and
- the compute environment (package and language versions)

If you'd like to add a workflow or make modifications to an existing one please do the following:

1. Fork the project.
```
# Press "Fork" at the top right of the GitHub page
```

2. Clone the fork and create a branch for your feature
```bash
git clone https://github.com/<USERNAME>/atomic-workflows.git
cd atomic-workflows
git checkout -b cool-new-feature
```

3. Make changes, add files, and commit
```bash
# make changes, add files, and commit them
git add file1.py file2.ipynb
git commit -m "I made these changes"
```

4. Push changes to GitHub
```bash
git push origin cool-new-feature
```

5. Submit a pull request with the following

	-  `README.md` containing 
	   - Inputs
	   - Preprocessing tools
	   - Preprocessing steps
	   - Outputs
	   - Metrics (and their utility)

	-  `spec.md`  with the assay sequencing library specification (defined with  [`seqspec`](https://github.com/IGVF/seqspec))
	-  `example.ipynb`  a Google Colab notebook executing the atomic workflow

**Note**: If you are unfamilar with pull requests, you find more information on the [GitHub help page.](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)
