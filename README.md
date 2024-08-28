## PCAdash
#### Visualization of PCA-Metegenes using R-Shiny at single-cell resolution

<a href="https://priyansh-srivastava.shinyapps.io/PCAdash/" target="_blank">
  <img src="https://img.shields.io/badge/Launch%20on%20ShinyAppsIO-009E73?style=for-the-badge" alt="Launch on shinyApps IO"></a>    <a href="https://priyansh-srivastava.shinyapps.io/PCAdash/" target="_blank">
  <img src="https://img.shields.io/badge/Launch%20on%20AWS%20EC2-0072B2?style=for-the-badge" alt="Launch on AWS-EC2">
</a>

---

### Introduction
<p align="justify" style="text-indent: 20px;">
`PCAdash` is an R-shiny application designed to visualize the results of PCA-Metagenes at single-cell resolution. The app follows a black theme and consists of two pages: the results page and the documentation page.
</p>

<p align="justify" style="text-indent: 20px;">
`PCAdash` is deployed on [shinyapps.io](https://www.shinyapps.io/) and AWS-EC2. Additionally, it is integrated with GitHub Actions for CI/CD, enabling automatic deployment on [shinyapps.io](https://www.shinyapps.io/) whenever a new commit is pushed to the `main` branch. The app also utilizes the R-CMD-Check workflow to ensure it is free from errors and warnings. Finally, the app is packaged within an R package named `PCAdash`.
</p>

---

### Motivation
<p align="justify" style="text-indent: 20px;">
I designed this application to present some of the work from my PhD project on PCA-Metagene inference and now it acts as one of my showcase project. Metagenes serve as summaries of gene sets (pathways) and illustrate the coordinated expression of genes within a particular set. This app was initially developed during the early years of my PhD program and later revamped to be more user-friendly and interactive. While most improvements focus on development and deployment, the introduction of a black theme is also a significant feature. Please refer to the documentation for more information about the app.
</p>

---

### CI/CD

[![R-CMD-Check](https://github.com/spriyansh/PCAdash/actions/workflows/cmd-check.yml/badge.svg?branch=main)](https://github.com/spriyansh/PCAdash/actions/workflows/cmd-check.yml)
[![ShinyAppsIO](https://github.com/spriyansh/PCAdash/actions/workflows/shinyAppsIO.yml/badge.svg?branch=main)](https://github.com/spriyansh/PCAdash/actions/workflows/shinyAppsIO.yml)


```mermaid
graph LR;
    feature/change-->|Pull-Request|Develop-Branch;
    Develop-Branch-->|Trigger|R-CMD-Check;
    change-->|Push|Develop-Branch;
    Develop-Branch-->|Pull-Request|Main-Branch;
    Main-Branch-->|Trigger|R-CMD-Check;
    Main-Branch-->|Trigger|Deploy-ShinyAppsIO;
    
```


---

<p align="center">
<a href="https://priyansh-srivastava.shinyapps.io/PCAdash/" target="_blank">
  <img src="https://img.shields.io/badge/Launch%20on%20ShinyAppsIO-009E73?style=for-the-badge" alt="Launch on shinyApps IO">
</a> <a href="https://priyansh-srivastava.shinyapps.io/PCAdash/" target="_blank">
  <img src="https://img.shields.io/badge/Launch%20on%20AWS%20EC2-0072B2?style=for-the-badge" alt="Launch on AWS-EC2">
</a>
</p>

---
