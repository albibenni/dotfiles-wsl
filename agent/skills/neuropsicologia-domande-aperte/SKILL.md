---
name: neuropsicologia-domande-aperte
description: Genera una serie di domande aperte su argomenti di neuropsicologia (es. funzioni cognitive, basi neurali, deficit clinici e test) in lingua italiana. Permette all'utente di scegliere il numero di domande e fornisce risposte strutturate composte da introduzione, svolgimento e conclusione, con una lunghezza di almeno 15 righe ciascuna.
---

# Neuropsicologia Domande Aperte

Questo skill ha lo scopo di facilitare lo studio e la preparazione di esami o approfondimenti clinici in neuropsicologia attraverso la generazione di domande aperte e la stesura di risposte strutturate, esaustive e rigorose.

## Workflow

1.  **Determinazione del Numero di Domande**: Identifica o chiedi all'utente il numero desiderato di domande aperte per la sessione di studio. Se non specificato, proponi un numero di default (es. 5 domande) chiedendo conferma.
2.  **Analisi del Contesto**: Esamina i testi, le dispense, le note o il contesto corrente per individuare i temi caldi della neuropsicologia clinica e sperimentale (es. afasie, modelli di memoria, aprassie, agnosie, funzioni esecutive, eminegligenza, sindromi frontali, plasticità cerebrale, ecc.).
3.  **Generazione delle Domande**: Formula domande aperte stimolanti che richiedano una comprensione concettuale profonda o l'applicazione di modelli clinici.
4.  **Presentazione e Salvataggio**: Mostra le domande all'utente. Salva contemporaneamente le domande e le risposte strutturate in un file chiamato `<argomento>_domande_aperte_neuro.md` nella cartella di destinazione.
5.  **Stesura delle Risposte Strutturate**: Per ciascuna domanda generata, produci una risposta dettagliata ed esaustiva che rispetti rigorosamente la struttura a tre parti (**Introduzione**, **Svolgimento**, **Conclusione**) e la lunghezza minima stabilita.

## Linee Guida per le Risposte

- **Struttura in Tre Parti**:
  - **Introduzione**: Definisce l'oggetto della domanda, inquadra storicamente o teoricamente l'argomento e fornisce le definizioni di base (es. cos'è l'aprassia ideomotoria).
  - **Svolgimento**: È il nucleo centrale della risposta. Deve descrivere i modelli teorici di riferimento (es. modello di Rothi e Heilman), le aree neuroanatomiche coinvolte (es. corteccia parietale sinistra, vie premotorie), le dissociazioni cliniche o sperimentali e i test di valutazione correlati.
  - **Conclusione**: Sintetizza brevemente quanto esposto, evidenziando le implicazioni clinico-riabilitative o le prospettive di ricerca future.
- **Lunghezza Minima**: Ciascuna risposta deve essere spiegata in modo estremamente approfondito e occupare **almeno 15 righe di testo** complessive. Evita risposte concise o superficiali.
- **Esclusione del Codice**: Questo skill è dedicato esclusivamente a materie umanistico-scientifiche e mediche. Non includere frammenti di codice, pseudo-codice o concetti estranei all'ambito neuropsicologico.
- **Rigore Scientifico**: Utilizza una terminologia accademica, formale e scientifica appropriata in italiano.
- **Formattazione dei Link**: Non usare MAI URL `file:///`, percorsi di sistema assoluti o link relativi nei file `.md` generati o modificati. Utilizza esclusivamente la sintassi Wikilink di Obsidian (es. `[[nome_nota]]` o `[[nome_nota|Testo]]`).
- **Accuratezza Clinica**: Radica le risposte nelle teorie consolidate e sui dati clinici del materiale fornito, offrendo spiegazioni basate sulle evidenze scientifiche.
