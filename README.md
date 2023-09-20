# Prova finale - Progetto di Reti Logiche A.A. 2021/2022

L'obiettivo di questa prova finale è stato la progettazione e l'implementazione di un componente in VHDL che operasse su una sequenza di byte, applicando al flusso di parole un codice convoluzionale con rapporto 1:2.

## Descrizione del progetto

Il componente si interfaccia con una memoria dalla quale legge una serie di parole da un byte, ogni parola viene serializzata per ottenere un flusso di 8 bit su cui applicare il codice convoluzionale descritto in figura. Il risultato è una sequenza da 16 bit, due byte, che vengono scritti e salvati in memoria. Di seguito viene riportato un esempio di funzionamento, con *Uk* si indica il flusso di bit della k-esima parola in ingresso, con *P1k* e *P2k* si indicano i flussi ottenuti alle due uscite del convolutore (con riferimento alla figura). Il risultato si ottiene concatenando i bit di uscita *P1k* e *P2k* in questo ordine (*P11-P21-P12-P22-P13-P23-P14-P24*...).

![Descrizione del convolutore](/images/convolutore.png "Convolutore")


Esempio di esecuzione. In ingresso la parola *01001011*, in uscita *00110111 11010010*

|  T  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-----|---|---|---|---|---|---|---|---|
| Uk  | 0 | 1 | 0 | 0 | 1 | 0 | 1 | 1 |
| P1k | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| P2k | 0 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |


## Test

Il componente è stato sottoposto a diversi casi di test regolari per verificarne il corretto funzionamento, oltre ad essi sono stati testati anche alcuni casi particolari:

- Reset asincrono - invio di un segnale di reset nel mezzo dell'esecuzione
- Sequenza massima - elaborazione del massimo numero di parole possibile (255)
- Sequenza nulla - nessuna parola in ingresso
- Doppia esecuzione - elaborazione delle stesse parole consecutivamente


## Conclusioni

Nel documento con le [specifiche](/specifications/Specifiche_progetto.pdf) della consegna è possibile avere una maggior chiarezza ed una maggior dettagliata descrizione del funzionamento richiesto dal componente. Il progetto è stato valutato 30/30 Cum Laude
