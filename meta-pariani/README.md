# meta-pariani

Layer Yocto per STM32MP151 basato su **Yocto Scarthgap**, con supporto Qt5 minimale (solo Widgets, senza QML o Multimedia), ottimizzato per backend Wayland/Weston con rendering software (Mesa/llvmpipe).

## Contenuto
- **conf/snippets/qt5-minimal-scarthgap.conf**  
  Configurazione minima di Qt5 (solo Widgets, Wayland, senza QML)
- **conf/distro/pariani-st.conf**  
  Distribuzione che include automaticamente la configurazione minima Qt5
- **recipes-core/images/pariani-qt-min-image.bb**  
  Immagine di esempio con Qt5 minimale

## Requisiti
- Branch Yocto **scarthgap**
- Layer `meta-qt5` aggiunto al manifest:
  ```xml
  <project name="meta-qt5/meta-qt5" path="layers/meta-qt5" remote="github" revision="scarthgap"/>

