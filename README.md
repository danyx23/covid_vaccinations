# covid_vaccinations

To run the scripts either install the R libraries manually or alternatively you can use VS Code with docker and the [Visual Studio Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers) extension that has all dependencies already installed and will not change your host OS.

To create the output plots and intermediate data files run the scripts in /src like this:
```bash
r deliveries.R
r extract_stiko_groups.R
r plot_vaccines_vs_people.R
```
