---
title: "[2x5] Generowanie interfejsu użytkownika"
course: "10xdevs-2"
source: "Przeprogramowani.pl"
exported: "2025-11-12"
format: "markdown"
---

![Ilustracja z lekcji](https://assets-v2.circle.so/f8rp0efgz3453pkhzeul6cksyd3q)

## Wprowadzenie

Programowanie z modelami językowymi to szansa na łatwiejsze tworzenie interfejsów użytkownika - ekspercki poziom znajomości CSSów nie jest wymagany!

Nie oznacza to jednak, że model - tak jak programista - może na własne oczy zobaczyć, poczuć i na bieżąco korygować efekty swojej pracy. Paradoksalnie, to ograniczenie LLMów jest najbardziej odczuwalne w warstwie UI, a tak trudne w interpretacji polecenia jak “utwórz ładny formularz” daje bardzo różne efekty i ma więcej wspólnego z ruletką niż frontend engineeringiem.

Aby ten problem zaadresować, pracę nad UI/UX sprowadzimy do jasnych poleceń względem elementów interfejsu, ich relacji, interakcji i wykorzystywanych bibliotek. Przy okazji postaramy się minimalizować liczbę niepowiązanych reguł CSS które łatwo pominąć, stawiając na spójne komponenty zawierające zarówno strukturę jak i określony sposób opisywania stylu (dzięki [shadcn/ui](https://ui.shadcn.com/) oraz [bibliotece Tailwind](https://tailwindcss.com/)).

Na początku kilka słów o fundamentach tej lekcji.

## Tailwind

![Ilustracja z lekcji](https://assets-v2.circle.so/g226bj8chccw0uf5hk6omf3hmqj8)

Tailwind CSS to framework utility-first, który pozwala na budowanie nowoczesnych interfejsów za pomocą predefiniowanych klas CSS stosowanych bezpośrednio w HTML. Zamiast pisać własne style, używasz gotowych klas jak flex, pt-4, text-center czy bg-blue-500.

### Korzyści ze stosowania Tailwind:

- **Szybkość tworzenia** \- projektowanie interfejsu bezpośrednio w HTML bez przełączania się między plikami
- **Spójność** \- predefiniowany system designu z ustalonymi wielkościami, kolorami i odstępami
- **Mała objętość CSS** \- produkcyjny build zawiera tylko wykorzystane klasy
- **Wysoka konfigurowalność** \- możliwość dostosowania kolorów, breakpointów, fontów i innych elementów za pomocą własnej konfiguracji (kiedyś w tailwind.config.js, od wersji 4 w pliku global.css)
- **Świetna dokumentacja** \- łatwo znajdziesz potrzebne klasy i ich zastosowanie

### Przykładowy fragment interfejsu z Tailwind:

```
<div >
  <button >
    Kliknij mnie
  </button>
</div>
```

![Ilustracja z lekcji](https://assets-v2.circle.so/ufg93asmadxi5p0kmz6sjj4ny40s)

Zwróć uwagę jak poszczególne klasy CSS składają się na finalny wygląd danego elementu:

- p-4 - to padding, czyli “wewnętrzny margines”
- bg-blue-500 - niebieskie tło, 500 oznacza środek palety (dostępny zakres to 50-950)
- hover:bg-blue-700 - konfiguracja tła z modyfikatorem hover - najechanie kursorem
- rounded - zaokrąglone rogi elementu, itd.

Tailwind doskonale współpracuje z LLMami, ponieważ nazwy klas są intuicyjne i samodzielnie dokumentujące się (np. text-center, mt-4). Dodatkowo, wygląd elementu opisywany jest w tym samym miejscu, w którym znajduje się jego struktura. Ułatwia to zarządzanie kontekstem dla AI.

Instrukcję instalacji Tailwinda w frameworkach webowych znajdziesz [pod tym linkiem](https://tailwindcss.com/docs/installation/framework-guides). 

Piaskownicę do testowania klas Tailwinda znajdziesz [pod tym linkiem](https://play.tailwindcss.com/).

**👉 W szablonie 10x-astro-starter konfiguracja Tailwinda została przeprowadzona już wcześniej - teraz możesz po prostu korzystać z potencjału frameworka.**

## Shadcn/ui

Shadcn/ui to rekomendowana przez nas kolekcja gotowych, dostosowywanych komponentów zbudowanych na React, [Radix UI](https://www.radix-ui.com/) i Tailwind.

W przeciwieństwie do tradycyjnych bibliotek, z których zaciągamy elementy bez wiedzy o szczegółach, shadcn/ui stosuje podejście oparte o generator komponentów wewnątrz projektu.

![Ilustracja z lekcji](https://assets-v2.circle.so/37lizwzxbx4i7c7zwhwk88f5776z)

### Cechy biblioteki:

- **Dostęp do kodu** \- komponenty stają się częścią twojego projektu, co daje pełną kontrolę nad ich modyfikacją
- **Przystępna złożoność** \- komponenty są zbudowane jak klocki, które można łatwo rozbudowywać
- **Dostępność** \- zbudowane na Radix UI, zapewniają dostępność (a11y) bez dodatkowej pracy
- **Elastyczność** \- łatwa zmiana stylów, kolorów i zachowań poprzez global.css, bez walki z abstrakcjami
- **Spójny design** \- wszystkie komponenty współpracują ze sobą wizualnie i funkcjonalnie

Połączenie Tailwind i shadcn/ui tworzy potężny ekosystem, który pozwala programistom (a także LLMom) tworzyć spójne, dostępne i estetyczne interfejsy użytkownika bez konieczności pisania tysięcy linijek własnego kodu HTML/CSS/JS - łatwego do pominięcia przez programistę i błędnie interpretowanego przez AI.

### 🚀 Konfiguracja shadcn/ui

Shadcn/ui wymaga odpowiedniej konfiguracji przed rozpoczęciem używania komponentów. Proces instalacji i konfiguracji składa się z kilku kluczowych kroków, w których centralną rolę odgrywa komenda init. 

**👉 W 10x-astro-starter shadcn/ui jest już skonfigurowane i gotowe do pracy.**

### Proces inicjalizacji shadcn/ui

Pierwszym krokiem jest inicjalizacja shadcn/ui w projekcie za pomocą komendy:

```
npx shadcn@latest init
```

Po uruchomieniu tej komendy, narzędzie przechodzi przez weryfikację bieżącej konfiguracji projektu, w tym sprawdzenia instalacji Tailwinda oraz dodania aliasów ścieżek w tsconfig.json.

Instrukcję instalacji shadcn/ui w frameworkach webowych znajdziesz [tutaj](https://ui.shadcn.com/docs/installation).

Ważne: wykonując komendę init nie korzystaj z flagi \`—defaults\`, chwilowo prowadzi ona do błędu, który jest powiązany z nowym Tailwind 4 ([Github Issue](https://github.com/shadcn-ui/ui/issues/6446)).

### Po inicjalizacji

Po zakończeniu procesu init, projekt jest gotowy do dodawania poszczególnych komponentów za pomocą komendy:

```
npx shadcn@latest add button card avatar
```

Każdy zainstalowany w ten sposób komponent trafia bezpośrednio do katalogu komponentów w projekcie, gdzie można go dowolnie modyfikować zgodnie z potrzebami.

Warto podkreślić, że shadcn/ui, w przeciwieństwie do tradycyjnych bibliotek komponentów, **nie jest zależnością projektu** \- to raczej zbiór szablonów, które po instalacji stają się integralną częścią kodu aplikacji. To właśnie dlatego inicjalizacja jest tak ważnym krokiem - ustawia ona cały ekosystem projektu pod kątem spójnego designu i organizacji kodu.

## Sesja planistyczna interfejsu użytkownika

🎥 **VIDEO**: [Watch here](https://player.vimeo.com/video/1072998313?app_id=122963&byline=0&badge=0&portrait=0&title=0)

Do sesji planistycznej wykorzystaj prompt z 10xRules.ai Prompt Library - [Asystent planowania architektury UI](https://10xrules.ai/prompts?org=10xdevs&collection=m2-bootstrap&segment=l5-ui&prompt=c7bfd30d-e413-41b7-85ee-026b092514bb).

Następnie, wykorzystaj prompt - [Podsumowanie sesji planowania architektury UI](https://10xrules.ai/prompts?org=10xdevs&collection=m2-bootstrap&segment=l5-ui&prompt=e4457a5f-2c9c-4828-97f2-81a67f920fa3).

## Generowanie wysokopoziomowego planu UI

🎥 **VIDEO**: [Watch here](https://player.vimeo.com/video/1072991790?app_id=122963&byline=0&badge=0&portrait=0&title=0)

Do wygenerowania ui-plan.md, wykorzystaj prompt - [**Generowanie wysokopoziomowego planu UI**](https://10xrules.ai/prompts?org=10xdevs&collection=m2-bootstrap&segment=l5-ui&prompt=c0f17d5a-0dc2-40da-b129-f69e838343c4)**.**

## Szczegółowy plan implementacji widoku do generowania fiszek

🎥 **VIDEO**: [Watch here](https://player.vimeo.com/video/1072991739?app_id=122963&byline=0&badge=0&portrait=0&title=0)

Do wygenerowania szczegółowego planu implementacji widoku wykorzystaj prompt - [**Szczegółowy plan implementacji widoku**](https://10xrules.ai/prompts?org=10xdevs&collection=m2-bootstrap&segment=l5-ui&prompt=629e6ff0-3fac-44d2-abc1-aa90c161a845)**.**

## Implementacja widoku generowania fiszek z shadcn/ui i Tailwind

🎥 **VIDEO**: [Watch here](https://player.vimeo.com/video/1072991671?app_id=122963&byline=0&badge=0&portrait=0&title=0)

Do zaimplementowania widoku wykorzystaj prompt - [Implementacja widoku](https://10xrules.ai/prompts?org=10xdevs&collection=m2-bootstrap&segment=l5-ui&prompt=60599924-a4e8-482f-b882-fbae38a77817).

Poniżej załączam również helpera, który pomaga agentowi efektywnie korzystać z biblioteki komponentów shadcn/ui (ui-shadcn-helper.mdc):

```
# Shadcn UI Components

Ten projekt wykorzystuje @shadcn/ui dla komponentów interfejsu użytkownika. Są to pięknie zaprojektowane, dostępne komponenty, które można dostosować do swojej aplikacji.

## Odszukiwanie zainstalowanych komponentów

Komponenty są dostępne w folderze `src/components/ui`, zgodnie z aliasami z pliku `components.json`

## Wykorzystanie komponentu

Zaimportuj komponent zgodnie ze skonfigurowanym aliasem `@/`

```tsx
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
```

Przykładowe wykorzystanie komponnetów:

```tsx
<Button variant="outline">Click me</Button>

<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Card Description</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Card Content</p>
  </CardContent>
  <CardFooter>
    <p>Card Footer</p>
  </CardFooter>
</Card>
```

## Instalowanie dodatkowych komponentów

Wiele innych komponentów jest dostępnych, ale nie są one obecnie zainstalowane. Pełną listę można znaleźć na stronie https://ui.shadcn.com/r

Aby zainstalować nowy komponent, wykorzystaj shadcn CLI

```bash
npx shadcn@latest add [component-name]
```

Przykładowo, aby dodać komponent accordion

```bash
npx shadcn@latest add accordion
```

Ważne: `npx shadcn-ui@latest` zostało wycofane, korzystaj z `npx shadcn@latest`

Niektóre popularne komponenty to:

- Accordion
- Alert
- AlertDialog
- AspectRatio
- Avatar
- Calendar
- Checkbox
- Collapsible
- Command
- ContextMenu
- DataTable
- DatePicker
- Dropdown Menu
- Form
- Hover Card
- Menubar
- Navigation Menu
- Popover
- Progress
- Radio Group
- ScrollArea
- Select
- Separator
- Sheet
- Skeleton
- Slider
- Switch
- Table
- Textarea
- Sonner (previously Toast)
- Toggle
- Tooltip

## Component Styling

Ten projekt wykorzystuje wariant stylu „new-york” z kolorem bazowym "neutral" i zmiennymi CSS do tworzenia motywów, zgodnie z konfiguracją w sekcji `components.json`.
```

### Model zaczyna się gubić? Podsumowanie i nowy wątek!

W przypadku bardziej skomplikowanych scenariuszy, gdzie potrzebujemy więcej niż 5-6 kroków działania modelu, okno kontekstowe może być wypełnione powyżej progu skuteczności modelu. Kiedy zauważysz taki problem, cofnij się do checkpointa, w którym zaczęły się problemy. 

Zamień poprzedniego prompta na prośbę o zatrzymanie implementacji i utworzenie pliku ze statusem prac   _.ai/{view-name}-implementation-status_, który wykorzystasz w nowym wątku:

```
Podsumuj swoją pracę w pliku .ai/{nazwa-zadania}-implementation-status.md w formacie markdown:

```markdown
# Status implementacji widoku {nazwa widoku}

## Zrealizowane kroki
[Szczegółowa lista zrealizowanych kroków]

## Kolejne kroki
[Lista dalszych kroków, zgodna z planem implementacji]
```

Po utworzeniu pliku ze statusem, napisz "Gotowe". Na tym zakończ pracę w tym wątku. 
```

Przeanalizuj też plik ze statusem - warto zwrócić uwagę na kolejne kroki gdzie może pojawić się scope creep, czyli aspiracyjne pomysły modelu, które wykraczają poza oryginalny zakres planu implementacji.

Pozbądź się tego co nie jest kluczowe. Ulepszenia i refaktoryzacje lepiej wprowadzać w dedykowanych konwersacjach skupionych na konkretnym celu (więcej o tym w kolejnym module). Na tym etapie warto skupić się na zrealizowaniu głównego celu jakim jest działający moduł, który spełnia kluczowe standardy. 

W nowym wątku wykorzystaj wariację poprzedniego prompta, który dodatkowo zawiera odniesienie do statusu implementacji:

```
Twoim zadaniem jest zaimplementowanie widoku frontendu w oparciu o podany plan implementacji i zasady implementacji. Twoim celem jest stworzenie szczegółowej i dokładnej implementacji, która jest zgodna z dostarczonym planem, poprawnie reprezentuje strukturę komponentów, integruje się z API i obsługuje wszystkie określone interakcje użytkownika.

Najpierw przejrzyj plan implementacji:

<implementation_plan>
{{implementation-plan}} <- zamień na referencję do planu implementacji widoku (np. @generations-view-implementation-plan.md)
</implementation_plan>

Teraz przejrzyj zasady implementacji:

<implementation_rules>
{{frontend-rules}}  <- zamień na referencję do reguł frontendowych (np. @shared.mdc, @frontend.mdc, @astro.mdc, @react.mdc, @ui-shadcn-helper.mdc)
</implementation_rules>

Przejrzyj zdefiniowane typy:

<types>
{{types}} <- zamień na referencję do definicji DTOsów (np. @types.ts)
</types>

Wdrażaj plan zgodnie z następującym podejściem:

<implementation_approach>
Realizuj maksymalnie 3 kroki planu implementacji, podsumuj krótko co zrobiłeś i opisz plan na 3 kolejne działania - zatrzymaj w tym momencie pracę i czekaj na mój feedback.
</implementation_approach>

Nie zaczynaj pracy od poczatku kroków implementacji, weź pod uwagę obecny status:

<implementation_status>
{{implementation-status}} <- zamień na referencję do utworzonego statusu implementacji 👈
</implementation_status>

Dokładnie przeanalizuj plan wdrożenia, zasady i jego obecny status (zacznij od "Następne kroki"). Zwróć szczególną uwagę na strukturę komponentów, wymagania dotyczące integracji API i interakcje użytkownika opisane w planie.

// reszta prompta taka sama jak w oryginalnym poleceniu implementacji
```

Takie podejście zaoszczędzi Ci dużo straconego czasu i frustracji.

## 🎨 Kreatywne inspiracje

Współpracując z AI nad budowaniem interfejsu użytkownika możesz wspomagać się też odniesieniami do popularnych stron i design systemów takich jak:

- [Google Material Design](https://m3.material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [Microsoft Fluent Design System](https://fluent2.microsoft.design/)
- [Carbon Design System od IBM](https://carbondesignsystem.com/)
- Airbnb / Booking / Uber / etc.

Pamiętaj jednak, że AI przede wszystkim bazuje na słownych opisach tego, jak wyglądają poszczególne elementy. Stąd, aby zainspirować się danym stylem, rozpocznij od planu opisującego cechy twojego idealnego projektu i wymagane korekty, a następnie wykonaj docelowe wdrożenie.

Taką formę edycji UI (oraz klasyczną, opartą o [generator motywów](https://tweakcn.com/editor/theme)) prezentujemy poniżej:

🎥 **VIDEO**: [Watch here](https://player.vimeo.com/video/1124327863?app_id=122963)

### Generowanie nowych komponentów

Jeśli w twojej aplikacji nie bazujesz na shadcn/ui, nowy motyw może wymagać przejścia na komponenty zaprojektowane w określony sposób.

Najpierw w trybie “Chat with AI” możesz poprosić o charakterystykę danego rozwiązania:

```
Jesteś specjalistą frontend developmentu tworzącym nowoczesne i przystępne interfejsy użytkownika.

Opisz cechy design systemu {{Microsoft Fluent 2.0 | Google Material 3}} pod kątem elementów takich jak:

1. Button
2. Input
3. Typography
4. Card
5. Modal/Dialog
6. Form
7. Navigation
8. List
9. Feedback
10. Layout
```

Na podstawie wygenerowanego opisu, w kolejnym prompcie możesz utworzyć zestaw gotowych do użycia komponentów (powyższą listę możesz modyfikować aby otrzymać inne komponenty):

```
W folderze src/components utwórz zestaw komponentów opartych o React/Tailwind w oparciu o te rekomendacje.

Implementacja powinna wykorzystywać najlepsze praktyki stylowania aplikacji Tailwind 4 (css variables i design tokens).
```

Po wygenerowaniu komponentów, całość można zaprezentować na tzw. stronach “kitchen sink”, które w jednym miejscu zbierają wszystkie elementy w formie demo:

```
Utwórz stronę typu "kitchen sink" (src/pages/kitchen-sink) prezentując nowo dodane komponenty w jednym miejscu.
```

“[Kitchen sink](https://conversionswp.com/bootstrap-5-kitchen-sink/)” to zwyczajowa nazwa strony, która ułatwia prezentację wszystkich elementów wchodzących w skład danego design systemu. Może być przydatna do szybkiej oceny komponentów, które utworzyliśmy przy współpracy z AI.

Poniżej przykłady działania tego scenariusza:

**Microsoft Fluent 2.0:**

![Ilustracja z lekcji](https://assets-v2.circle.so/b3ezjsg1vw0sncxr3e5eg5t625aj)

**Apple Human Interface Guidelines:**

![Ilustracja z lekcji](https://assets-v2.circle.so/vbnwfaxoz658buvgsse5792z8x58)

**Airbnb:**

![Ilustracja z lekcji](https://assets-v2.circle.so/xhisx8eokmrb4jq4rhay10g1dppm)

**Uber:**

![Ilustracja z lekcji](https://assets-v2.circle.so/6t0at4o7066uewbnkc3m06rf0hfx)

Dzięki komponentom wygenerowanym w ten sposób otrzymujesz swój lokalny, oparty o komponenty design system, którego cechy możesz dodatkowo zachować w pliku Markdown (opis z pierwszego prompta) i wykorzystywać do rozszerzania o nowe elementy. Im bardziej popularną inspirację wybierzesz, tym lepsze efekty już za pierwszym razem.

Przy generowaniu komponentu możesz dodatkowo wskazać na “rules for AI” pod Reacta i Tailwinda, aby zadbać o poprawną konstrukcję każdego elementu. To szybki sposób na udany UI!

## 🏁 Podsumowanie

W tej lekcji poznaliśmy kluczowe aspekty budowania interfejsów użytkownika z wykorzystaniem nowoczesnych narzędzi i bibliotek:

- **Tailwind CSS** \- framework utility-first, który pozwala na tworzenie interfejsów za pomocą predefiniowanych klas CSS bez pisania własnych styli. Oferuje szybkość tworzenia, spójność, małą objętość kodu oraz wysoką konfigurowalność.
- **Shadcn/ui** \- kolekcja gotowych komponentów zbudowanych na React, Radix UI i Tailwind, które stają się częścią projektu. Daje to pełną kontrolę nad kodem, zapewnia dostępność, elastyczność i spójny design.
- **Planowanie architektury UI** \- metodyczne podejście do projektowania interfejsu, wykorzystujące sesje planistyczne, generowanie wysokopoziomowego planu UI oraz tworzenie szczegółowych planów implementacji poszczególnych widoków.
- **Implementacja widoków** \- strukturyzowany proces obejmujący budowę komponentów, integrację z API, obsługę interakcji użytkownika, zarządzanie stanem, stylowanie oraz obsługę błędów zgodnie z przyjętymi zasadami i specyfikacją.
- **Kreatywne inspiracje** \- możliwość wykorzystania popularnych systemów projektowych (Material Design, Human Interface Guidelines, Fluent Design) jako inspiracji przy tworzeniu własnych komponentów, z wykorzystaniem stron typu "kitchen sink" do prezentacji elementów.

Pamiętaj, że programowanie z LLM w kontekście UI to szansa na szybsze tworzenie interfejsów użytkownika, ale wymaga jasnych poleceń i strukturyzowanego podejścia. Najlepsze rezultaty osiąga się łącząc AI z dobrze zdefiniowanymi komponentami i frameworkami CSS, które minimalizują potrzebę generowania skomplikowanych, niepowiązanych reguł stylowania.

## 👨‍💻 Ćwiczenia praktyczne

**Zadanie 1: Zaincjalizuj bibliotekę komponentów**   
**Cel:** Skonfigurowanie biblioteki komponentów w swoim projekcie.   
**Instrukcje:**

1. Jeśli korzystasz z Reacta, zaincjalizuj shadcn/ui w swoim projekcie
2. Jeśli korzystasz z innego frameworka, wybierz i zainstaluj odpowiednią bibliotekę komponentów
3. Upewnij się, że podstawowe komponenty (Button, Card, Input) są dostępne do użycia
4. Sprawdź poprawność konfiguracji tworząc prosty przykład wykorzystujący te komponenty
5. Zapoznaj się z dokumentacją wybranej biblioteki, aby zrozumieć dostępne opcje konfiguracji

**Zadanie 2: Przeprowadź sesję planistyczną dla interfejsu użytkownika**   
**Cel:** Zdefiniowanie założeń i struktury interfejsu użytkownika dla Twojej aplikacji.   
**Instrukcje:**

1. Wykorzystaj prompt z sekcji "Sesja planistyczna interfejsu użytkownika"
2. Przeprowadź minimum dwie rundy pytań i odpowiedzi dotyczących planowanego interfejsu
3. Wygeneruj podsumowanie sesji planistycznej
4. Zapisz wyniki jako punkt odniesienia do dalszych prac

**Zadanie 3: Wygeneruj wysokopoziomowy plan UI**   
**Cel:** Stworzenie kompleksowego planu architektury interfejsu użytkownika.   
**Instrukcje:**

1. Wykorzystaj prompt z sekcji "Generowanie wysokopoziomowego planu UI"
2. Wygeneruj i poddaj rewizji plan UI za pomocą modelu reasoningowego
3. Zapisz wygenerowany plan jako .ai/ui-plan.md
4. Upewnij się, że plan zawiera wszystkie kluczowe widoki, mapę podróży użytkownika oraz strukturę nawigacji

**Zadanie 4: Stwórz szczegółowy plan implementacji widoku**   
**Cel:** Opracowanie szczegółowego planu wdrożenia kluczowego widoku aplikacji.   
**Instrukcje:**

1. Wybierz kluczowy widok dla Twojej aplikacji z wysokopoziomowego planu UI
2. Wykorzystaj prompt z sekcji "Szczegółowy plan implementacji widoku"
3. Dostosuj prompt, uwzględniając specificzne endpointy API i typy danych
4. Wygeneruj szczegółowy plan implementacji widoku
5. Zapisz plan jako .ai/{nazwa-widoku}-view-implementation-plan.md
6. Upewnij się, że plan zawiera kluczowe komponenty, warunki walidacji, typy, obsługę stanu oraz sensowny plan implementacji krok po kroku

**Zadanie 5: Zaimplementuj widok**   
**Cel:** Pełna implementacja widoku zgodnie z wygenerowanym planem.   
**Instrukcje:**

1. Wykorzystaj prompt z sekcji "Implementacja widoku z shadcn/ui i Tailwind"
2. Jeśli korzystasz z shadcn/ui, dołącz ui-shadcn-helper.mdc do implementation\_rules
3. Etapowo wdrażaj plan implementacji, korzystając z workflow 3×3 (3 kroki implementacji, feedback, kolejne 3 kroki)
4. Upewnij się, że implementacja obejmuje wszystkie komponenty, integrację z API oraz obsługę interakcji użytkownika
5. Przetestuj zaimplementowany widok pod kątem funkcjonalności i zgodności z planem
6. W razie potrzeby wprowadź poprawki lub rozszerzenia

![Ilustracja z lekcji](https://assets-v2.circle.so/bhe5tn2ay37vnkh8spzbevyv6jp5)