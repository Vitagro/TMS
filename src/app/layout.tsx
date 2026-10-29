import './globals.css';
export const metadata = { title: 'FRETLOOP | TMS', description: 'FRETLOOP — Connecter, optimiser, boucler. Gestion de transport et de sous-traitance en MAD.', icons: {icon: '/fretloop-logo.png'} };
export default function Layout({children}:{children:React.ReactNode}) { return <html lang="fr"><body>{children}</body></html>; }
