# Prova finale - Progetto di Reti Logiche A.A. 2021/2022

L'obiettivo di questa prova finale è stato la progettazione e l'implementazione di un componente in VHDL che operasse su una sequenza di byte, applicando al flusso di parole un codice convoluzionale con rapporto 1:2.

## Descrizione del progetto

Il componente si interfaccia con una memoria dalla quale legge una serie di parole da un byte, ogni parola viene serializzata per ottenere un flusso di 8 bit su cui applicare il codice convoluzionale descritto in figura. Il risultato è una sequenza da 16 bit, due byte, che vengono scritti e salvati in memoria. Di seguito viene riportato un esempio di funzionamento, con *Uk* si indica il k-esimo bit della parola in ingresso, con *P1k* e *P2k* si indicano i flussi ottenuti alle due uscite del convolutore (con riferimento alla figura). Il risultato si ottiene concatenando i bit di uscita *P1k* e *P2k* in questo ordine (*P11-P21-P12-P22-P13-P23-P14-P24*...).

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



---

# Final test - Progetto di Reti Logiche A.Y. 2021/2022

This project aims at applying the knowledge acquired from the Reti Logiche (Digital Circuits Design) course held at Politecnico di Milano University to design and implement, using an HW description language (VHDL), an HW component able to perform specific required operations. This year's project's main goal was to design a component able to apply a convolutional code over a sequence of 1-byte-long words.

## Description

The designed component communicates with a memory component from which it reads each word one at a time, it serializes the byte obtaining a stream of bits to which it then applies the convolutional code described in figure below. The code has a rate of 1/2, meaning that the output is twice as long as the input, so the 16-bit stream obtained as result is split into two words that are then written in the memory component. Below the figure is an example of execution, *Uk* represents the k-th bit of the input word, *P1k* and *P2k* represent the two bits obtained as a result as shown in figure. The overall result is the concatenation of the output bits *P1k* and *P2k* in this order (*P11-P21-P12-P22-P13-P23-P14-P24*...).

![Description of convolutional code](/images/convolutore.png "Convolutional code")


Example of execution. Word *01001011* is taken as input, the result is *00110111 11010010*

|  T  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-----|---|---|---|---|---|---|---|---|
| Uk  | 0 | 1 | 0 | 0 | 1 | 0 | 1 | 1 |
| P1k | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| P2k | 0 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |


## Test cases

Several regular test cases have been applied in order to verify the correctness of the implemented component, other more specific tests were intended to check anomalous or edge cases:

- Asyncronous reset - sending a reset signal during regular execution
- Maximum sequence - execution over the maximum amount of words possible (255)
- Null sequence - no input words
- Double execution - execution over the same input repeated twice right after


## Conclusions

The [document](/specifications/Specifiche_progetto.pdf) containing the project's specifications has a clearer and more detailed description of the component's requested behavior. The project has been evaluated 30/30 Cum Laude
